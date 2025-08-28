class_name GameManager
extends Node2D
##############################################################
#                      0.0 Signals                           #
##############################################################
signal level_set
signal turn_started(turn_number: int)
signal turn_ended(turn_number: int)
signal unit_turn_ended(unit: Unit, unit_tile: Vector2i)
signal unit_died(unit: Unit)
signal unit_spawned(unit: Unit)
signal unit_removed(unit: Unit)

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var UnitScene: PackedScene
@export var CombatScreenScene: PackedScene
@export var VfxScene: PackedScene

@export var ManagerTimer: Timer
@export var ActionMenu: PanelContainer
@export var EndScreen: CanvasLayer
@export var ActiveUnitInfoPanel: PanelContainer
@export var SelectedUnitInfoPanel: PanelContainer
@export var ActionForecast: PanelContainer
@export var MyCursor: GridCursor

@export var MyMoveManager: MoveManager
@export var MyActionManager: ActionManager

var CurrentLevel : Level
var CurrentLevelManager: LevelManager
var GroundGrid : TileMapLayer
var HighlightLayer : TileMapLayer

######################
#     SCRIPT-WIDE    #
######################
enum GameState {NULL, PLAYER_TURN, ENEMY_TURN}
enum SubState {NULL, UNIT_SELECTION_PHASE, ACTION_SELECTION_PHASE, TARGETING_PHASE, MOVEMENT_PHASE, ACTION_CONFIRMATION_PHASE, PROCESSING_PHASE}
var CurrentGameState = GameState.NULL
var CurrentSubState = SubState.NULL

var PlayerUnits: Array[Unit] = []
var EnemyUnits: Array[Unit] = []
var UnitsWhoHaveActed: Array[Unit] = []

var TurnNumber: int = 0
var NumberOfUnits : int = 0 #For unit naming

var ActiveUnit: Unit = null
var TargetedUnit: Unit = null
var CurrentAction : Action = null

##############################################################
#                      2.0 Functions                         #
##############################################################

func Wait(seconds: float):
	ManagerTimer.wait_time = seconds
	ManagerTimer.start()
	await ManagerTimer.timeout

##############################################################
#                      2.1 SET GAME                          #
##############################################################

func SetLevel():
	CurrentLevel = GameData.selected_level.instantiate()
	add_child(CurrentLevel)
	CurrentLevelManager = CurrentLevel.MyLevelManager
	GroundGrid = CurrentLevel.GroundGrid
	HighlightLayer = CurrentLevel.HighlightLayer

func SetAuxiliaryManagers():
	CurrentLevelManager.initialize(self)
	level_set.emit()
	MyMoveManager.initialize(self)
	MyActionManager.initialize(self)

func SetCursor():
	
	var initial_position : Vector2i = Vector2i(0, 0)
	initial_position = GroundGrid.local_to_map(PlayerUnits[0].global_position)
	MyCursor.MoveToTile(initial_position, GroundGrid)
	DisplaySelectedUnitInfo()

##############################################################
#                      2.2 UI                                #
##############################################################

func HideUI():
	ActionMenu.HideMenu()
	ActiveUnitInfoPanel.hide()
	SelectedUnitInfoPanel.hide()

#func DisplayClickedUnitInfo(clicked_tile: Vector2i) -> bool:
	#for unit in PlayerUnits:
		#if clicked_tile == GroundGrid.local_to_map(unit.global_position):
			#if unit == ActiveUnit:
				#return true
			#else:
				#SelectedUnitInfoPanel.UpdatePanel(unit)
				#return true
	#for unit in EnemyUnits:
		#if clicked_tile == GroundGrid.local_to_map(unit.global_position):
			#SelectedUnitInfoPanel.UpdatePanel(unit)
			#return true
	#return false

func DisplaySelectedUnitInfo():
	var unit_found = false
	var all_units : Array[Unit] = PlayerUnits + EnemyUnits
	for unit in all_units:
		if MyCursor.TilePosition == GroundGrid.local_to_map(unit.global_position):
			SelectedUnitInfoPanel.UpdatePanel(unit)
			unit_found = true
			break
	
	if not unit_found:
		SelectedUnitInfoPanel.UpdatePanel(null)

func CheckGridBounds(tile: Vector2i) -> bool:
	var grid_rect = GroundGrid.get_used_rect()
	return grid_rect.has_point(tile)

##############################################################
#                      2.3 SPAWNING                          #
##############################################################

func FindClosestValidSpawn(start_tile: Vector2i, occupied_tiles: Array[Vector2i], unit_data: UnitData) -> Vector2i:
	var move_data_name = unit_data.MovementType.Name
	
	if not MyMoveManager.AStarInstances.has(move_data_name):
		push_error("No AStar grid found for movement type: " + move_data_name)
		return start_tile
	
	var astar = MyMoveManager.AStarInstances[move_data_name]
	
	var check_queue: Array[Vector2i] = [start_tile]
	var queued: Array[Vector2i] = [start_tile]
	
	while not check_queue.is_empty():
		var current_tile = check_queue.pop_front()
		
		var point_id = MyMoveManager.vector_to_id(current_tile)
		if astar.has_point(point_id) and not astar.is_point_disabled(point_id) and not occupied_tiles.has(current_tile):
			return current_tile
		
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		for direction in directions:
			var neighbor = current_tile + direction
			if not queued.has(neighbor):
				queued.append(neighbor)
				check_queue.push_back(neighbor)
	
	push_warning("Could not find a valid spawn point for a unit at " + str(start_tile))
	return start_tile

func SpawnUnit(spawn_info : SpawnInfo):
	var unit_data = spawn_info.UnitClass
	var spawn_pos = spawn_info.Position
	var new_unit: Unit = UnitScene.instantiate()
	
	new_unit.Data = unit_data
	new_unit.Faction = spawn_info.Faction
	
	if spawn_info.Faction != Unit.Factions.PLAYER:
		new_unit.AI = spawn_info.AI
	
	new_unit.name = "%s %s %d" % [Unit.Factions.find_key(spawn_info.Faction)[0], unit_data.Name, NumberOfUnits]
	NumberOfUnits += 1
	add_child(new_unit)
	
	match spawn_info.Faction:
		Unit.Factions.PLAYER:
			PlayerUnits.append(new_unit)
		Unit.Factions.ENEMY:
			EnemyUnits.append(new_unit)
	
	var occupied_tiles = MyMoveManager.GetOccupiedTiles()
	if occupied_tiles.has(spawn_pos):
		spawn_pos = FindClosestValidSpawn(spawn_pos, occupied_tiles, unit_data)
	var tile_grid_position = GroundGrid.map_to_local(spawn_pos)
	var tile_global_position = GroundGrid.to_global(tile_grid_position)
	new_unit.global_position = tile_global_position
	
	new_unit.unit_died.connect(_on_unit_died)
	new_unit.vfx_requested.connect(_on_vfx_requested)
	unit_spawned.emit(new_unit)


func SpawnUnitGroup(spawn_list: Array[SpawnInfo]):
	for spawn_info in spawn_list:
		SpawnUnit(spawn_info)

func DefinePlayerUnits():
	for i in range(GameData.player_units.size()):
		CurrentLevel.PlayerSpawns[i].UnitClass = GameData.player_units[i]

func SpawnStartingUnits():
	SpawnUnitGroup(CurrentLevel.PlayerSpawns)
	SpawnUnitGroup(CurrentLevel.EnemySpawns)

##############################################################
#                      2.4 GAME FLOW                         #
##############################################################

func StartPlayerTurn():
	CurrentGameState = GameState.PLAYER_TURN
	CurrentSubState = SubState.UNIT_SELECTION_PHASE
	print("Player turn begins.")
	UnitsWhoHaveActed.clear()
	for player in PlayerUnits:
		player.StartTurn()
	TurnNumber += 1
	turn_started.emit(TurnNumber)

func OnPlayerActionFinished():
	CurrentSubState = SubState.ACTION_SELECTION_PHASE
	ActionMenu.ShowMenu(ActiveUnit)

func EndPlayerTurn():
	if not ActiveUnit: return
	
	var unit_tile = GroundGrid.local_to_map(ActiveUnit.global_position)
	unit_turn_ended.emit(ActiveUnit, unit_tile)
	
	UnitsWhoHaveActed.append(ActiveUnit)
	ActiveUnit = null
	
	if UnitsWhoHaveActed.size() == PlayerUnits.size():
		turn_ended.emit(TurnNumber)
		await Wait(0.5)
		await StartEnemyTurn()
	else:
		CurrentSubState = SubState.UNIT_SELECTION_PHASE

func StartEnemyTurn():
	print("--- Enemy Turn Begins ---")
	CurrentGameState = GameState.ENEMY_TURN
	CurrentSubState = SubState.MOVEMENT_PHASE
	
	for enemy in EnemyUnits:
		await Wait(0.2)
		enemy.StartTurn()
		print(enemy.name + " is taking its turn.")
		await enemy.AI.execute_turn(enemy, self)
		var enemy_tile = GroundGrid.local_to_map(enemy.global_position) 
		unit_turn_ended.emit(enemy, enemy_tile)
	
	print("--- Enemy Turn Ends ---")
	StartPlayerTurn()

func EndGame(player_won: bool):
	HideUI()
	get_tree().paused = true
	EndScreen.ShowEndScreen(player_won)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_direction_pressed(direction: Vector2i):
	# We only want the cursor to move in specific phases.
	var valid_cursor_phase : bool = CurrentSubState in [SubState.UNIT_SELECTION_PHASE, SubState.TARGETING_PHASE]
	if not CurrentGameState == GameState.PLAYER_TURN or not valid_cursor_phase:
		return
	
	var new_position = MyCursor.TilePosition + direction
	if CheckGridBounds(new_position):
		MyCursor.MoveToTile(new_position, GroundGrid)
		DisplaySelectedUnitInfo()

func _on_confirm_pressed():
	# We will add logic here in the next step
	pass

func _on_cancel_pressed():
	# We will add logic here in the next step
	pass

func _on_action_menu_action_selected(action: Action) -> void:
	HideUI()
	action._on_select(ActiveUnit, self)

func _on_end_screen_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_spawn_requested(spawn_array: Array[SpawnInfo]):
	SpawnUnitGroup(spawn_array)

func _on_unit_died(unit: Unit):
	if unit in PlayerUnits:
		PlayerUnits.erase(unit)
	elif unit in EnemyUnits:
		EnemyUnits.erase(unit)
	unit_removed.emit(unit)
	unit_died.emit(unit)
	unit.queue_free()

func _on_vfx_requested(vfx_data: VFXData, animation_name: String, vfx_position: Vector2, is_combat: bool):
	if is_combat == true:
		return
	if not vfx_data:
		push_warning("Failed to load VFX Data")
		return

	var vfx: VFX = VfxScene.instantiate()
	add_child(vfx)

	vfx.SetData(vfx_data)
	vfx.global_position = vfx_position
	vfx.MyAnimationPlayer.play("vfx/" + animation_name)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

#func _unhandled_input(event):
	#if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		#return
	#
	#match CurrentGameState:
		#GameState.PLAYER_TURN:
					#var global_mouse_position = get_global_mouse_position()
					#var grid_mouse_position = GroundGrid.to_local(global_mouse_position)
					#var clicked_tile = GroundGrid.local_to_map(grid_mouse_position)
					#var unit_clicked : bool = false
					#
					#match CurrentSubState:
						#
						#SubState.UNIT_SELECTION_PHASE:
							#unit_clicked = DisplayClickedUnitInfo(clicked_tile)
							#for unit in PlayerUnits:
								#if not unit in UnitsWhoHaveActed and clicked_tile == GroundGrid.local_to_map(unit.global_position):
									#HideUI()
									#ActiveUnit = unit
									#ActiveUnitInfoPanel.UpdatePanel(ActiveUnit)
									#ActionMenu.ShowMenu(ActiveUnit)
									#CurrentSubState = SubState.ACTION_SELECTION_PHASE
									#break
							#if unit_clicked == false:
								#HideUI()
						#
						#SubState.ACTION_SELECTION_PHASE:
							#unit_clicked = DisplayClickedUnitInfo(clicked_tile)
							#if unit_clicked == false:
								#HideUI()
								#CurrentSubState = SubState.UNIT_SELECTION_PHASE
						#
						#SubState.TARGETING_PHASE:
							#var target = null
							#
							#if MyActionManager.HighlightedMoveTiles.has(clicked_tile):
								#target = clicked_tile
								#MyActionManager.ClearHighlights()
								#CurrentSubState = SubState.PROCESSING_PHASE
								#await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, target)
								#return
							#
							#if MyActionManager.HighlightedAttackTiles.has(clicked_tile):
								#for enemy in EnemyUnits:
									#var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
									#if enemy_tile == clicked_tile:
										#target = enemy
										#break
										#
							#if MyActionManager.HighlightedHealTiles.has(clicked_tile):
								#for ally in PlayerUnits:
									#var ally_tile = GroundGrid.local_to_map(ally.global_position)
									#if ally_tile == clicked_tile:
										#target = ally
										#break
							#
							#if target is Unit:
								#TargetedUnit = target
								#await MyActionManager.PreviewAction(CurrentAction, ActiveUnit, TargetedUnit, true)
								#CurrentSubState = SubState.ACTION_CONFIRMATION_PHASE
								#return
							#
							#else:
								#unit_clicked = DisplayClickedUnitInfo(clicked_tile)
								#if unit_clicked == false:
									#HideUI()
									#MyActionManager.ClearHighlights()
									#ActionMenu.ShowMenu(ActiveUnit)
									#CurrentAction = null
									#CurrentSubState = SubState.ACTION_SELECTION_PHASE
						#
						#SubState.ACTION_CONFIRMATION_PHASE:
							#ActionForecast.hide()
							#MyActionManager.ClearHighlights()
							#
							#var target_tile = GroundGrid.local_to_map(TargetedUnit.global_position)
							#
							#if clicked_tile == GroundGrid.local_to_map(TargetedUnit.global_position):
								#CurrentSubState = SubState.PROCESSING_PHASE
								#await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, TargetedUnit)
								#EndPlayerTurn()
							#else:
								#TargetedUnit = null
								#CurrentAction = null
								#ActionMenu.ShowMenu(ActiveUnit)
								#CurrentSubState = SubState.ACTION_SELECTION_PHASE

func _ready() -> void:
	if not GameData.selected_level:
		push_warning("GameData is empty. Loading default Level for testing.")
		GameData.selected_level = GameData.TestLevel
		var class_data = GameData.TestClass
		GameData.player_units = [class_data]
	
	InputManager.direction_pressed.connect(_on_direction_pressed)
	InputManager.confirm_pressed.connect(_on_confirm_pressed)
	InputManager.cancel_pressed.connect(_on_cancel_pressed)
	
	SetLevel()
	
	SetAuxiliaryManagers()
	
	DefinePlayerUnits()
	SpawnStartingUnits()
	
	SetCursor()
	
	StartPlayerTurn()
