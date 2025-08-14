extends Node2D
@export var PlayerScene: PackedScene
@export var StartingPlayerClasses: Array[UnitData]
@export var StartingPlayerPositions: Array[Vector2i]
@export var GroundGrid: TileMapLayer
@export var HighlightLayer: TileMapLayer
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

var AstarGrid = AStarGrid2D.new()
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

func SetUnitObstacles(active_unit: Unit):
	var modified_tiles: Array[Vector2i] = []
	
	for unit in PlayerUnits:
		if unit != active_unit:
			var unit_tile = GroundGrid.local_to_map(unit.global_position)
			if active_unit.Faction != unit.Faction:
				AstarGrid.set_point_weight_scale(unit_tile, 999.0)
				modified_tiles.append(unit_tile)
			
	for enemy in EnemyUnits:
		if enemy != active_unit:
			var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
			if active_unit.Faction != enemy.Faction:
				AstarGrid.set_point_weight_scale(enemy_tile, 999.0)
				modified_tiles.append(enemy_tile)
	
	return modified_tiles

func ClearUnitObstacles(tiles_to_clear: Array[Vector2i]):
	for tile in tiles_to_clear:
		AstarGrid.set_point_weight_scale(tile, 1.0)

func GetOccupiedTiles() -> Array[Vector2i]:
	var occupied_tiles: Array[Vector2i] = []
	
	for unit in PlayerUnits:
		occupied_tiles.append(GroundGrid.local_to_map(unit.global_position))
	for enemy in EnemyUnits:
		occupied_tiles.append(GroundGrid.local_to_map(enemy.global_position))
	
	return occupied_tiles

func GetReachableTiles(unit: Unit,start_tile: Vector2i, move_range: int) -> Array[Vector2i]:
	var modified_tiles = SetUnitObstacles(unit)
	var tiles_to_check: Array[Vector2i] = [start_tile]
	var checked_tiles_costs: Dictionary = {start_tile: 0}
	
	var checked_tiles = 0
	while checked_tiles < tiles_to_check.size():
		var current_tile = tiles_to_check[checked_tiles]
		checked_tiles += 1
		
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		for direction in directions:
			var adjacent_tile = current_tile + direction
			
			var tile_data = GroundGrid.get_cell_tile_data(adjacent_tile)
			if not tile_data:
				continue
				
			var terrain_cost = tile_data.get_custom_data("move_cost")
			if terrain_cost <= 0:
				continue
			var obstacle_weight = AstarGrid.get_point_weight_scale(adjacent_tile)
			var move_cost = terrain_cost * obstacle_weight
			
			var new_cost = checked_tiles_costs[current_tile] + move_cost
			
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
	ClearUnitObstacles(modified_tiles)
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
	var move_range = unit.Data.MoveRange
	
	HighlightedMoveTiles = GetReachableTiles(unit, unit_grid_position, move_range)
	
	DrawHighlights(HighlightedMoveTiles, 1, Vector2i(0,0))

func SetAstarGrid():
	var map_rect = GroundGrid.get_used_rect()
	AstarGrid.region = map_rect
	AstarGrid.update()
	
	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var tile_coordinate = Vector2i(x, y)
			var tile_data = GroundGrid.get_cell_tile_data(tile_coordinate)
			if tile_data:
				var move_cost = tile_data.get_custom_data("move_cost")
				if move_cost < 1:
					AstarGrid.set_point_solid(tile_coordinate)

func FindPath(unit: Unit, start_tile: Vector2i, end_tile: Vector2i) -> Array[Vector2i]:
	
	var modified_tiles = SetUnitObstacles(unit)
	
	var astar_path = AstarGrid.get_point_path(start_tile, end_tile)
	var path: Array[Vector2i] = []
	for tile in astar_path:
		path.append(Vector2i(tile))
	
	ClearUnitObstacles(modified_tiles)
	
	return path

func GetPathCost(path: Array[Vector2i]) -> int:
	var total_cost = 0
	for i in range(1, path.size()):
		var tile_coord = path[i]
		var tile_data = GroundGrid.get_cell_tile_data(tile_coord)
		if tile_data:
			total_cost += tile_data.get_custom_data("move_cost")
	return total_cost

func FindClosestPlayerTo(unit: Unit) -> Unit:
	var closest_players: Array[Unit] = []
	var min_player_dist = 9999
	var enemy_tile = GroundGrid.local_to_map(unit.global_position)
	
	for player in PlayerUnits:
		var player_tile = GroundGrid.local_to_map(player.global_position)
		var path_to_player = FindPath(unit, enemy_tile, player_tile)
		if not path_to_player.is_empty():
			var path_cost = GetPathCost(path_to_player)
			if path_cost < min_player_dist:
				min_player_dist = path_cost
				closest_players.clear()
				closest_players.append(player)
			elif path_cost == min_player_dist:
				closest_players.append(player)
	
	if closest_players.is_empty():
		print(unit.name + "has no path to player units")
		return null
	else:
		return closest_players.pick_random()

func FindBestDestination(unit: Unit, reachable_tiles: Array[Vector2i], target_tile: Vector2i) -> Vector2i:
	var best_target_tiles: Array[Vector2i] = []
	var min_path_cost = 9999
	
	for tile in reachable_tiles:
		var path_from_tile = FindPath(unit, tile, target_tile)
		if not path_from_tile.is_empty():
			var path_cost = GetPathCost(path_from_tile)
			if path_cost < min_path_cost:
				min_path_cost = path_cost
				best_target_tiles.clear()
				best_target_tiles.append(tile)
			elif path_cost == min_path_cost:
				best_target_tiles.append(tile)
	
	if best_target_tiles.is_empty():
		return Vector2i(-1, -1)
	else:
		return best_target_tiles.pick_random()

func MoveUnit(unit: Unit, target_tile: Vector2i) -> Tween:
	var start_tile = GroundGrid.local_to_map(unit.global_position)
	var path = FindPath(unit, start_tile, target_tile)
	
	if path.is_empty():
		return null
	
	var tween = create_tween()
	tween.set_parallel(false)
	
	for step in path:
		var step_global_position = GroundGrid.to_global(GroundGrid.map_to_local(step))
		tween.tween_property(unit, "global_position", step_global_position, 0.2)
	
	match CurrentGameState:
		GameState.PLAYER_TURN:
			CurrentSubState = PlayerTurnState.PROCESSING_PHASE
			tween.tween_callback(OnPlayerActionFinished)
		
		GameState.ENEMY_TURN:
			CurrentSubState = EnemyTurnState.PROCESSING_PHASE
	
	return tween

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
	for i in range(StartingPlayerClasses.size()):
		var unit_data = StartingPlayerClasses[i]
		var spawn_pos = StartingPlayerPositions[i]
		
		var new_unit: Unit = PlayerScene.instantiate()
		new_unit.name = unit_data.Name + str(i)
		
		new_unit.Data = unit_data
		new_unit.Faction = Unit.Factions.PLAYER
		
		add_child(new_unit)
		PlayerUnits.append(new_unit)
		
		var tile_grid_position = GroundGrid.map_to_local(spawn_pos)
		var tile_global_position = GroundGrid.to_global(tile_grid_position)
		new_unit.global_position = tile_global_position

func SpawnEnemy(spawn_tile: Vector2i):
	var new_enemy: Unit = EnemyScene.instantiate()
	new_enemy.name = "Enemy" + str(EnemyUnits.size())
	add_child(new_enemy)
	
	var tile_grid_position = GroundGrid.map_to_local(spawn_tile)
	var tile_global_position = GroundGrid.to_global(tile_grid_position)
	new_enemy.global_position = tile_global_position
	
	EnemyUnits.append(new_enemy)

func HideUI():
	ActionMenu.hide()
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
		print(enemy.name + " is taking its turn.")
		
		var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
		var target_player = FindClosestPlayerTo(enemy)
		if not target_player:
			await Wait(0.5)
			continue
		
		var target_player_tile = GroundGrid.local_to_map(target_player.global_position)
		var reachable_tiles = GetReachableTiles(enemy, enemy_tile, enemy.Data.MoveRange)
		var best_target_tile = FindBestDestination(enemy, reachable_tiles, target_player_tile)
		
		if best_target_tile == enemy_tile or best_target_tile == Vector2i(-1, -1):
			await Wait(0.5)
		else:
			var move_tween = MoveUnit(enemy, best_target_tile)
			if move_tween:
				await move_tween.finished
		
		var current_enemy_tile = GroundGrid.local_to_map(enemy.global_position)
		if AreTilesInRange(enemy.Data.AttackRange, current_enemy_tile, target_player_tile):
			#Will be completed when we adapt enemies to use Actions rather than using this function
			await Wait(0.5)
			
	print("--- Enemy Turn Ends ---")
	EndEnemyTurn()

func EndPlayerTurn():
	if not ActiveUnit: return
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

func _unhandled_input(event):
	match CurrentGameState:
		GameState.PLAYER_TURN:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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
						
					#PlayerTurnState.MOVEMENT_PHASE:
						#unit_clicked = DisplayClickedUnitInfo(clicked_tile)
						#if unit_clicked == false:
							#HideUI()
							#if HighlightedMoveTiles.has(clicked_tile):
								#ClearHighlights()
								#MoveUnit(ActiveUnit, clicked_tile)
							#else:
								#ClearHighlights()
								#ActionMenu.ShowMenu(ActiveUnit)
								#CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
					#
					#PlayerTurnState.ATTACK_PHASE:
						#var enemy_on_tile = null
						#
						#if HighlightedAttackTiles.has(clicked_tile):
							#for enemy in EnemyUnits:
								#var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
								#if enemy_tile == clicked_tile:
									#enemy_on_tile = enemy
									#break
						#
						#if enemy_on_tile:
							#TargetedUnit = enemy_on_tile
							#var damage = ActiveUnit.Data.AttackPower
							#ActionForecast.UpdateForecast(ActiveUnit, TargetedUnit, damage)
							#ActionForecast.global_position = TargetedUnit.global_position + Vector2(10, -10)
							#ActionForecast.show()
							#CurrentSubState = PlayerTurnState.ACTION_CONFIRMATION_PHASE
						#else:
							#ClearHighlights()
							#ActionMenu.ShowMenu(ActiveUnit)
							#CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
					
					#PlayerTurnState.HEAL_PHASE:
						#var ally_on_tile = null
						#
						#if HighlightedHealTiles.has(clicked_tile):
							#for ally in PlayerUnits:
								#var ally_tile = GroundGrid.local_to_map(ally.global_position)
								#if ally_tile == clicked_tile:
									#ally_on_tile = ally
									#break
						#
						#if ally_on_tile:
							#TargetedUnit = ally_on_tile
							#var amount = ActiveUnit.Data.HealPower
							#ActionForecast.UpdateForecast(ActiveUnit, TargetedUnit, amount)
							#ActionForecast.global_position = TargetedUnit.global_position + Vector2(10, -10)
							#ActionForecast.show()
							#CurrentSubState = PlayerTurnState.ACTION_CONFIRMATION_PHASE
						#else:
							#ClearHighlights()
							#ActionMenu.ShowMenu(ActiveUnit)
							#CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
					#
					PlayerTurnState.ACTION_CONFIRMATION_PHASE:
						ActionForecast.hide()
						ClearHighlights()
						if clicked_tile == GroundGrid.local_to_map(TargetedUnit.global_position):
							ExecuteAction(CurrentAction, ActiveUnit, TargetedUnit)
						else:
							TargetedUnit = null
							CurrentAction = null
							ActionMenu.ShowMenu(ActiveUnit)
							CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE

func _on_end_screen_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _ready() -> void:
	SetAstarGrid()
	SpawnPlayerUnits()
	SpawnEnemy(Vector2i(10, 5))
	SpawnEnemy(Vector2i(12, 7))
	StartGame()

func _on_action_menu_action_selected(action: Action) -> void:
	HideUI()
	action._on_select(ActiveUnit)

func ExecuteAction(action: Action, unit: Unit, target = null):
	action._execute(unit, target)
	CurrentAction = null

func ForecastAction(action: Action, unit: Unit, target: Unit):
	var simulated_target = target.duplicate() as Unit
	add_child(simulated_target)
	simulated_target.visible = false

	ExecuteAction(action, unit, simulated_target)

	var damage = target.CurrentHP - simulated_target.CurrentHP
	ActionForecast.UpdateForecast(unit, target, damage)
	
	ActionForecast.global_position = target.global_position + Vector2(10, -10)
	ActionForecast.show()

	simulated_target.queue_free()
