class_name GameManager
extends Node2D

signal level_set
signal unit_turn_ended(unit: Unit, unit_tile: Vector2i)
signal unit_died(unit: Unit)

var CurrentLevel : Level
var CurrentLevelManager: LevelManager
var GroundGrid : TileMapLayer
var HighlightLayer : TileMapLayer
@export var PlayerScene: PackedScene
@export var ManagerTimer: Timer
@export var ActionMenu: PanelContainer
@export var EnemyScene: PackedScene
@export var EndScreen: CanvasLayer
@export var ActiveUnitInfoPanel: PanelContainer
@export var ClickedUnitInfoPanel: PanelContainer
@export var ActionForecast: PanelContainer

var PlayerUnits: Array[Unit] = []
var EnemyUnits: Array[Unit] = []
var ActiveUnit: Unit = null
var TargetedUnit: Unit = null
var UnitsWhoHaveActed: Array[Unit] = []

enum GameState {NULL, PLAYER_TURN, ENEMY_TURN}
enum PlayerTurnState {NULL, UNIT_SELECTION_PHASE, ACTION_SELECTION_PHASE, TARGETING_PHASE, MOVEMENT_PHASE, ACTION_CONFIRMATION_PHASE, PROCESSING_PHASE}
enum EnemyTurnState {NULL, MOVEMENT_PHASE, PROCESSING_PHASE}
var CurrentGameState = GameState.NULL
var CurrentSubState = PlayerTurnState.NULL

var CurrentAction : Action = null

var AStarInstances: Dictionary = {}
var HighlightedMoveTiles: Array[Vector2i] = []
var HighlightedAttackTiles: Array[Vector2i] = []
var HighlightedHealTiles: Array[Vector2i] = []
var SpawnTile = Vector2i(3,5)

func Wait(seconds: float):
	ManagerTimer.wait_time = seconds
	ManagerTimer.start()
	await ManagerTimer.timeout

func GetTilesInRange(start_tile: Vector2i, action_range: int) -> Array[Vector2i]:
	var tiles_in_range: Array[Vector2i] = []
	
	for x in range(-action_range, action_range + 1):
		for y in range(-action_range, action_range + 1):
			var distance = abs(x) + abs(y)
			if distance <= action_range:
				tiles_in_range.append(start_tile + Vector2i(x, y))
	
	tiles_in_range.erase(start_tile)
	return tiles_in_range

func SetUnitObstacles(active_unit: Unit, astar : AStar2D):
	if active_unit.ActiveStatuses.has(Unit.Status.PASS):
		return []
	
	var modified_tiles: Array[Vector2i] = []
	
	for unit in PlayerUnits:
		if unit != active_unit:
			var unit_tile = GroundGrid.local_to_map(unit.global_position)
			if active_unit.Faction != unit.Faction:
				astar.set_point_disabled(vector_to_id(unit_tile), true)
				modified_tiles.append(unit_tile)
			
	for enemy in EnemyUnits:
		if enemy != active_unit:
			var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
			if active_unit.Faction != enemy.Faction:
				astar.set_point_disabled(vector_to_id(enemy_tile), true)
				modified_tiles.append(enemy_tile)
	
	return modified_tiles

func ClearUnitObstacles(tiles_to_clear: Array[Vector2i], astar : AStar2D):
	for tile in tiles_to_clear:
		astar.set_point_disabled(vector_to_id(tile), false)

func GetOccupiedTiles() -> Array[Vector2i]:
	var occupied_tiles: Array[Vector2i] = []
	
	for unit in PlayerUnits:
		occupied_tiles.append(GroundGrid.local_to_map(unit.global_position))
	for enemy in EnemyUnits:
		occupied_tiles.append(GroundGrid.local_to_map(enemy.global_position))
	
	return occupied_tiles

func GetReachableTiles(unit: Unit, start_tile: Vector2i) -> Array[Vector2i]:
	var move_range = unit.Data.MoveRange
	if not unit.Data.MovementType:
		push_error(unit.name + " has no MovementData assigned.")
		return []
	var move_data_name = unit.Data.MovementType.Name
	if not AStarInstances.has(move_data_name):
		push_error("No AStar grid found for movement type: " + move_data_name)
		return []
	var astar = AStarInstances[move_data_name]
	
	var modified_tiles = SetUnitObstacles(unit, astar)
	var tiles_to_check: Array[Vector2i] = [start_tile]
	var checked_tiles_costs: Dictionary = {start_tile: 0}
	
	var checked_tiles = 0
	while checked_tiles < tiles_to_check.size():
		var current_tile = tiles_to_check[checked_tiles]
		checked_tiles += 1
		
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		for direction in directions:
			var adjacent_tile = current_tile + direction
			
			if not astar.has_point(vector_to_id(adjacent_tile)) or astar.is_point_disabled(vector_to_id(adjacent_tile)):
				continue
			
			var tile_data = GroundGrid.get_cell_tile_data(adjacent_tile)
			if not tile_data:
				continue
			
			var terrain_type: String = tile_data.get_custom_data("terrain_type")
			var terrain_cost = unit.Data.MovementType.TerrainCosts.get(terrain_type, -1)
			if terrain_cost == -1:
				continue
			
			var new_cost = checked_tiles_costs[current_tile] + terrain_cost
			
			if new_cost <= move_range:
				if not checked_tiles_costs.has(adjacent_tile) or new_cost < checked_tiles_costs[adjacent_tile]:
					checked_tiles_costs[adjacent_tile] = new_cost
					tiles_to_check.push_back(adjacent_tile)
					
	var all_reachable_tiles = checked_tiles_costs.keys()
	var reachable_tiles: Array[Vector2i] = []
	
	var occupied_tiles = GetOccupiedTiles()
	for tile in all_reachable_tiles:
		if not occupied_tiles.has(tile) or tile == start_tile:
			reachable_tiles.append(tile)
	
	reachable_tiles.erase(start_tile)
	ClearUnitObstacles(modified_tiles, astar)
	return reachable_tiles

func DrawHighlights(tiles_to_highlight:Array[Vector2i], highlight_source_id:int, highlight_atlas_coord:Vector2i):
	for tile in tiles_to_highlight:
		HighlightLayer.set_cell(tile, highlight_source_id, highlight_atlas_coord)

func ClearHighlights():
	HighlightLayer.clear()
	HighlightedMoveTiles.clear()
	HighlightedAttackTiles.clear()
	HighlightedHealTiles.clear()

func HighlightMoveArea(unit: Unit):
	ClearHighlights()
	var unit_grid_position = GroundGrid.local_to_map(unit.global_position)
	
	HighlightedMoveTiles = GetReachableTiles(unit, unit_grid_position)
	
	DrawHighlights(HighlightedMoveTiles, 1, Vector2i(0,0))

func SetAStarGrids():
	var all_movement_data: Array[MovementData] = []
	var path = "res://Resources/MovementData/"
	
	var dir = DirAccess.open(path)
	if dir:
		for file_name in dir.get_files():
			var resource = load(path + file_name)
			all_movement_data.append(resource)
	else:
		push_error("Could not find MovementData directory at: " + path)
	
	for move_data in all_movement_data:
		var new_astar = MovementAStar.new()
		new_astar.GroundGrid = GroundGrid
		new_astar.MovementType = move_data
		var all_cells = GroundGrid.get_used_cells()
		
		for cell in all_cells:
			var tile_data = GroundGrid.get_cell_tile_data(cell)
			if tile_data:
				var terrain_type: String = tile_data.get_custom_data("terrain_type")
				var move_cost = move_data.TerrainCosts.get(terrain_type, -1) # Default to -1 if type not found
				
				var point_id = vector_to_id(cell)
				new_astar.add_point(point_id, cell)
				
				if move_cost == -1:
					new_astar.set_point_disabled(point_id, true)
		
		for cell in all_cells:
			var current_point_id = vector_to_id(cell)
			if not new_astar.has_point(current_point_id) or new_astar.is_point_disabled(current_point_id):
				continue
			
			var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
			for direction in directions:
				var neighbor_cell = cell + direction
				var neighbor_point_id = vector_to_id(neighbor_cell)
				
				if new_astar.has_point(neighbor_point_id) and not new_astar.is_point_disabled(neighbor_point_id):
					new_astar.connect_points(current_point_id, neighbor_point_id)
					
		AStarInstances[move_data.Name] = new_astar

func FindPath(unit: Unit, start_tile: Vector2i, end_tile: Vector2i) -> Dictionary:
	var move_data_name = unit.Data.MovementType.Name
	if not AStarInstances.has(move_data_name):
		push_error("No AStar grid found for movement type: " + move_data_name)
		return {}
	var astar : AStar2D = AStarInstances[move_data_name]
	
	var modified_tiles = SetUnitObstacles(unit, astar)
	var start_id = vector_to_id(start_tile)
	var end_id = vector_to_id(end_tile)
	
	var astar_path_vectors = astar.get_point_path(start_id, end_id)
	
	var path: Array[Vector2i] = []
	for tile in astar_path_vectors:
		path.append(Vector2i(tile))
	
	if path.is_empty():
		ClearUnitObstacles(modified_tiles, astar)
		return {"path": [], "cost": INF} # Return an infinite cost to signify failure.
	
	var path_cost = 0
	for i in range(1, path.size()):
		var tile_coord = path[i]
		var tile_data = GroundGrid.get_cell_tile_data(tile_coord)
		if tile_data:
			var terrain_type: String = tile_data.get_custom_data("terrain_type")
			path_cost += unit.Data.MovementType.TerrainCosts.get(terrain_type, 1)
		
	ClearUnitObstacles(modified_tiles, astar)
	
	return {"path" : path, "cost" : path_cost}

func AreTilesInRange(action_range: int, tile1: Vector2i, tile2: Vector2i) -> bool:
	var distance = abs(tile1.x - tile2.x) + abs(tile1.y - tile2.y)
	return distance > 0 and distance <= action_range 

func HighlightAttackArea(unit: Unit, action_range: int):
	ClearHighlights()
	var unit_tile = GroundGrid.local_to_map(unit.global_position)
	HighlightedAttackTiles = GetTilesInRange(unit_tile, action_range)
	DrawHighlights(HighlightedAttackTiles, 1, Vector2i(1,0))

func HighlightHealArea(unit: Unit, action_range: int):
	ClearHighlights()
	var unit_tile = GroundGrid.local_to_map(unit.global_position)
	HighlightedHealTiles = GetTilesInRange(unit_tile, action_range)
	DrawHighlights(HighlightedHealTiles, 1, Vector2i(2,0))

func SpawnPlayerUnits():
	for i in range(GameData.player_units.size()):
		var unit_data = GameData.player_units[i]
		var spawn_info = CurrentLevel.PlayerSpawns[i]
		var spawn_pos = spawn_info.Position
		
		var new_unit: Unit = PlayerScene.instantiate()
		new_unit.name = unit_data.Name + str(i + 1)
		
		new_unit.Data = unit_data
		new_unit.Faction = Unit.Factions.PLAYER
		
		add_child(new_unit)
		PlayerUnits.append(new_unit)
		
		var tile_grid_position = GroundGrid.map_to_local(spawn_pos)
		var tile_global_position = GroundGrid.to_global(tile_grid_position)
		new_unit.global_position = tile_global_position
		new_unit.unit_died.connect(_on_unit_died)

func SpawnEnemyUnits():
	for i in range(CurrentLevel.EnemySpawns.size()):
		var spawn_info = CurrentLevel.EnemySpawns[i]
		var unit_data = spawn_info.UnitClass
		var spawn_pos = spawn_info.Position
		
		var new_unit: Unit = EnemyScene.instantiate()
		new_unit.name = "E " + unit_data.Name + str(i)
		
		new_unit.Data = unit_data
		new_unit.AI = spawn_info.AI
		new_unit.Faction = Unit.Factions.ENEMY
		
		add_child(new_unit)
		EnemyUnits.append(new_unit)
		
		var tile_grid_position = GroundGrid.map_to_local(spawn_pos)
		var tile_global_position = GroundGrid.to_global(tile_grid_position)
		new_unit.global_position = tile_global_position
		new_unit.unit_died.connect(_on_unit_died)

func HideUI():
	ActionMenu.HideMenu()
	ActiveUnitInfoPanel.hide()
	ClickedUnitInfoPanel.hide()

func StartGame():
	CurrentGameState = GameState.PLAYER_TURN
	CurrentSubState = PlayerTurnState.UNIT_SELECTION_PHASE

func EndGame(player_won: bool):
	HideUI()
	get_tree().paused = true
	EndScreen.ShowEndScreen(player_won)

func EndEnemyTurn():
	CurrentGameState = GameState.PLAYER_TURN
	CurrentSubState = PlayerTurnState.UNIT_SELECTION_PHASE
	print("Player turn begins.")
	UnitsWhoHaveActed.clear()
	for player in PlayerUnits:
		player.StartTurn()

func StartEnemyTurn():
	print("--- Enemy Turn Begins ---")
	
	for enemy in EnemyUnits:
		enemy.StartTurn()
		print(enemy.name + " is taking its turn.")
		await enemy.AI.execute_turn(enemy, self)
		var enemy_tile = GroundGrid.local_to_map(enemy.global_position) 
		unit_turn_ended.emit(enemy, enemy_tile)
	
	print("--- Enemy Turn Ends ---")
	EndEnemyTurn()

func EndPlayerTurn():
	if not ActiveUnit: return
	
	var unit_tile = GroundGrid.local_to_map(ActiveUnit.global_position)
	unit_turn_ended.emit(ActiveUnit, unit_tile)
	
	UnitsWhoHaveActed.append(ActiveUnit)
	ActiveUnit = null
	
	if UnitsWhoHaveActed.size() == PlayerUnits.size():
		CurrentGameState = GameState.ENEMY_TURN
		CurrentSubState = EnemyTurnState.MOVEMENT_PHASE
		print("Enemy turn begins.")
		StartEnemyTurn()
	else:
		CurrentSubState = PlayerTurnState.UNIT_SELECTION_PHASE

func OnPlayerActionFinished():
	CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
	ActionMenu.ShowMenu(ActiveUnit)

func DisplayClickedUnitInfo(clicked_tile: Vector2i) -> bool:
	for unit in PlayerUnits:
		if clicked_tile == GroundGrid.local_to_map(unit.global_position):
			if unit == ActiveUnit:
				return true
			else:
				ClickedUnitInfoPanel.UpdatePanel(unit)
				return true
	for unit in EnemyUnits:
		if clicked_tile == GroundGrid.local_to_map(unit.global_position):
			ClickedUnitInfoPanel.UpdatePanel(unit)
			return true
	return false

func ExecuteAction(action: Action, unit: Unit, target = null):
	action._execute(unit, self, target)
	CurrentAction = null
	TargetedUnit = null

func SimulateAction(action: Action, unit: Unit, target = null):
	action._execute(unit, self, target)

func ForecastAction(action: Action, unit: Unit, target: Unit):
	var simulated_target = target.duplicate() as Unit
	add_child(simulated_target)
	simulated_target.CopyState(target)

	SimulateAction(action, unit, simulated_target)
	
	var damage = target.CurrentHP - simulated_target.CurrentHP
	ActionForecast.UpdateForecast(unit, target, damage)
	
	simulated_target.queue_free()

func SetLevel():
	var level_scene = load(GameData.selected_level)
	if not level_scene:
		push_error("Failed to load level scene from path: " + GameData.selected_level)
		return
	CurrentLevel = level_scene.instantiate()
	add_child(CurrentLevel)
	CurrentLevelManager = CurrentLevel.MyLevelManager
	GroundGrid = CurrentLevel.GroundGrid
	HighlightLayer = CurrentLevel.HighlightLayer

func SetLevelManager():
	CurrentLevelManager.PlayerUnits = PlayerUnits
	CurrentLevelManager.EnemyUnits = EnemyUnits
	CurrentLevelManager.victory.connect(EndGame.bind(true))
	CurrentLevelManager.defeat.connect(EndGame.bind(false))
	unit_turn_ended.connect(CurrentLevelManager._on_unit_turn_ended)
	unit_died.connect(CurrentLevelManager._on_unit_died)
	level_set.connect(CurrentLevelManager._on_level_set)

func _unhandled_input(event):
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	match CurrentGameState:
		GameState.PLAYER_TURN:
					var global_mouse_position = get_global_mouse_position()
					var grid_mouse_position = GroundGrid.to_local(global_mouse_position)
					var clicked_tile = GroundGrid.local_to_map(grid_mouse_position)
					var unit_clicked : bool = false
					
					match CurrentSubState:
						
						PlayerTurnState.UNIT_SELECTION_PHASE:
							unit_clicked = DisplayClickedUnitInfo(clicked_tile)
							for unit in PlayerUnits:
								if not unit in UnitsWhoHaveActed and clicked_tile == GroundGrid.local_to_map(unit.global_position):
									HideUI()
									ActiveUnit = unit
									ActiveUnitInfoPanel.UpdatePanel(ActiveUnit)
									ActionMenu.ShowMenu(ActiveUnit)
									CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
									break
							if unit_clicked == false:
								HideUI()
						
						PlayerTurnState.ACTION_SELECTION_PHASE:
							unit_clicked = DisplayClickedUnitInfo(clicked_tile)
							if unit_clicked == false:
								HideUI()
								CurrentSubState = PlayerTurnState.UNIT_SELECTION_PHASE
						
						PlayerTurnState.TARGETING_PHASE:
							var target = null
							
							if HighlightedMoveTiles.has(clicked_tile):
								target = clicked_tile
								ClearHighlights()
								ExecuteAction(CurrentAction, ActiveUnit, target)
								return
							
							if HighlightedAttackTiles.has(clicked_tile):
								for enemy in EnemyUnits:
									var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
									if enemy_tile == clicked_tile:
										target = enemy
										break
										
							if HighlightedHealTiles.has(clicked_tile):
								for ally in PlayerUnits:
									var ally_tile = GroundGrid.local_to_map(ally.global_position)
									if ally_tile == clicked_tile:
										target = ally
										break
							
							if target is Unit:
								TargetedUnit = target
								ForecastAction(CurrentAction, ActiveUnit, TargetedUnit)
								CurrentSubState = PlayerTurnState.ACTION_CONFIRMATION_PHASE
								return
							
							else:
								unit_clicked = DisplayClickedUnitInfo(clicked_tile)
								if unit_clicked == false:
									HideUI()
									ClearHighlights()
									ActionMenu.ShowMenu(ActiveUnit)
									CurrentAction = null
									CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
						
						PlayerTurnState.ACTION_CONFIRMATION_PHASE:
							ActionForecast.hide()
							ClearHighlights()
							if clicked_tile == GroundGrid.local_to_map(TargetedUnit.global_position):
								ExecuteAction(CurrentAction, ActiveUnit, TargetedUnit)
								EndPlayerTurn()
							else:
								TargetedUnit = null
								CurrentAction = null
								ActionMenu.ShowMenu(ActiveUnit)
								CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE

func _on_action_menu_action_selected(action: Action) -> void:
	HideUI()
	action._on_select(ActiveUnit, self)

func _on_unit_died(unit: Unit):
	unit_died.emit(unit)
	unit.queue_free()

func _on_end_screen_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _ready() -> void:
	if GameData.selected_level == "":
		push_warning("GameData is empty. Loading default Level 1 for testing.")
		GameData.selected_level = "res://Scenes/Levels/level_1.tscn"
		var knight_data = load("res://Resources/ClassData/PlayerClassData/knight_data.tres")
		var priest_data = load("res://Resources/ClassData/PlayerClassData/priest_data.tres")
		GameData.player_units = [knight_data, priest_data]
	
	SetLevel()
	SetAStarGrids()
	
	SpawnPlayerUnits()
	SpawnEnemyUnits()
	
	SetLevelManager()
	level_set.emit()
	
	StartGame()

func vector_to_id(vector: Vector2i) -> int:
	# Converts a Vector2i coordinate to a unique integer ID.
	# This is necessary because AStar2D identifies points with integer IDs, not vectors.
	# We use a large number to ensure the y-coordinate doesn't overlap with the x-coordinate.
	return vector.x * 1000 + vector.y
