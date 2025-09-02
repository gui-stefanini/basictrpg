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

@export var MyActionMenu: ActionMenu

@export var ActiveUnitInfoPanel: PanelContainer
@export var SelectedUnitInfoPanel: PanelContainer
@export var ActionForecast: PanelContainer
@export var MyCursor: GridCursor

@export var InfoScreen: CanvasLayer
@export var EndScreen: CanvasLayer

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
var AllUnits: Array[Unit] = []
var UnitsWhoHaveActed: Array[Unit] = []

var TurnNumber: int = 0
var NumberOfUnits : int = 0 #For unit naming

var ActiveUnit: Unit = null
var TargetedUnit: Unit = null
var CurrentAction : Action = null
var OriginalUnitTile: Vector2i

##############################################################
#                      2.0 Functions                         #
##############################################################

func ConnectInputSignals():
	InputManager.confirm_pressed.connect(_on_confirm_pressed)
	InputManager.cancel_pressed.connect(_on_cancel_pressed)
	InputManager.info_pressed.connect(_on_info_pressed)
	InputManager.start_pressed.connect(_on_start_pressed)
	InputManager.left_trigger_pressed.connect(on_trigger_pressed.bind(-1))
	InputManager.right_trigger_pressed.connect(on_trigger_pressed.bind(1))
	InputManager.direction_pressed.connect(_on_direction_pressed)

func ClearInputSignals():
	InputManager.confirm_pressed.disconnect(_on_confirm_pressed)
	InputManager.cancel_pressed.disconnect(_on_cancel_pressed)
	InputManager.info_pressed.disconnect(_on_info_pressed)
	InputManager.start_pressed.disconnect(_on_start_pressed)
	InputManager.left_trigger_pressed.disconnect(on_trigger_pressed.bind(-1))
	InputManager.right_trigger_pressed.disconnect(on_trigger_pressed.bind(1))
	InputManager.direction_pressed.disconnect(_on_direction_pressed)

##############################################################
#                      2.1 SET GAME                          #
##############################################################

func SetLevel():
	CurrentLevel = GameData.SelectedLevelScene.instantiate()
	add_child(CurrentLevel)
	CurrentLevelManager = CurrentLevel.MyLevelManager
	GroundGrid = CurrentLevel.GroundGrid
	HighlightLayer = CurrentLevel.HighlightLayer

func SetAuxiliaryManagers():
	CurrentLevelManager.Initialize(self)
	MyMoveManager.Initialize(self)
	MyActionManager.Initialize(self)

func SetInfoScreen():
	InfoScreen.Initialize(self)

func SetCursor():
	var initial_position : Vector2i = Vector2i(0, 0)
	initial_position = GroundGrid.local_to_map(PlayerUnits[0].global_position)
	MyCursor.MoveToTile(initial_position, GroundGrid)
	DisplaySelectedUnitInfo()
	MyCursor.show()

func SetAudio():
	AudioManager.PlayBGM(CurrentLevelManager.LevelBGM)

##############################################################
#                      2.2 UI                                #
##############################################################

func HideUI():
	MyActionMenu.HideMenu()
	ActiveUnitInfoPanel.hide()
	SelectedUnitInfoPanel.hide()
	MyCursor.hide()

func DisplaySelectedUnitInfo():
	var unit_on_tile : Unit = GetUnitAtTile(MyCursor.TilePosition)
	
	if unit_on_tile == null:
		SelectedUnitInfoPanel.UpdatePanel(null)
	
	else:
		SelectedUnitInfoPanel.UpdatePanel(unit_on_tile)

func UpdateCursor(new_tile_position: Vector2i = Vector2i (-1,-1)):
	if new_tile_position != Vector2i(-1,-1):
		if CheckGridBounds(new_tile_position):
			MyCursor.MoveToTile(new_tile_position, GroundGrid)
	DisplaySelectedUnitInfo()
	MyCursor.show()

func CheckGridBounds(tile: Vector2i) -> bool:
	var grid_rect = GroundGrid.get_used_rect()
	return grid_rect.has_point(tile)

func GetUnitAtTile(tile_pos: Vector2i) -> Unit:
	for unit in AllUnits:
		if GroundGrid.local_to_map(unit.global_position) == tile_pos:
			return unit
	return null

##############################################################
#                      2.3 SPAWNING                          #
##############################################################

func FindClosestValidSpawn(start_tile: Vector2i, occupied_tiles: Array[Vector2i], unit_data: CharacterData) -> Vector2i:
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
	var unit_data = spawn_info.Character
	var spawn_pos = spawn_info.Position
	var new_unit: Unit = UnitScene.instantiate()
	
	new_unit.Data = unit_data
	new_unit.Faction = spawn_info.Faction
	
	if spawn_info.Faction != Unit.Factions.PLAYER:
		new_unit.AI = spawn_info.AI
	
	new_unit.SetData(spawn_info.CharacterLevel)
	new_unit.name = "%s %s %d" % [Unit.Factions.find_key(spawn_info.Faction)[0], unit_data.Name, NumberOfUnits]
	NumberOfUnits += 1
	add_child(new_unit)
	
	match spawn_info.Faction:
		Unit.Factions.PLAYER:
			PlayerUnits.append(new_unit)
		Unit.Factions.ENEMY:
			EnemyUnits.append(new_unit)
	AllUnits = PlayerUnits + EnemyUnits
	
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
	for i in range(CurrentLevel.PlayerSpawns.size()):
		CurrentLevel.PlayerSpawns[i].Character = GameData.PlayerUnits[i]

func SpawnStartingUnits():
	SpawnUnitGroup(CurrentLevel.PlayerSpawns)
	SpawnUnitGroup(CurrentLevel.EnemySpawns)

##############################################################
#                      2.4 GAME FLOW                         #
##############################################################
func SetActiveUnit(unit: Unit):
	ActiveUnit = unit
	OriginalUnitTile = GroundGrid.local_to_map(unit.global_position)

func ClearActiveUnit():
	ActiveUnit = null
	OriginalUnitTile = Vector2i (-1,-1)

func StartPlayerTurn():
	CurrentGameState = GameState.PLAYER_TURN
	CurrentSubState = SubState.UNIT_SELECTION_PHASE
	print("Player turn begins.")
	UnitsWhoHaveActed.clear()
	for unit in PlayerUnits:
		unit.StartTurn()
	TurnNumber += 1
	UpdateCursor()
	turn_started.emit(TurnNumber)

func OnPlayerActionFinished():
	CurrentSubState = SubState.ACTION_SELECTION_PHASE
	MyActionMenu.ShowMenu(ActiveUnit)

func EndPlayerTurn():
	if not ActiveUnit: return
	
	var unit_tile = GroundGrid.local_to_map(ActiveUnit.global_position)
	unit_turn_ended.emit(ActiveUnit, unit_tile)
	
	UnitsWhoHaveActed.append(ActiveUnit)
	ActiveUnit.SetInactive()
	ClearActiveUnit()
	
	if UnitsWhoHaveActed.size() == PlayerUnits.size():
		HideUI()
		for unit in PlayerUnits:
			unit.SetActive()
		turn_ended.emit(TurnNumber)
		await GeneralFunctions.Wait(0.5)
		await StartEnemyTurn()
	else:
		CurrentSubState = SubState.UNIT_SELECTION_PHASE

func StartEnemyTurn():
	print("--- Enemy Turn Begins ---")
	CurrentGameState = GameState.ENEMY_TURN
	CurrentSubState = SubState.MOVEMENT_PHASE
	
	for enemy in EnemyUnits:
		await GeneralFunctions.Wait(0.2)
		enemy.StartTurn()
		print(enemy.Data.Name + " is taking its turn.")
		await enemy.AI.execute_turn(enemy, self)
		var enemy_tile = GroundGrid.local_to_map(enemy.global_position) 
		unit_turn_ended.emit(enemy, enemy_tile)
	
	print("--- Enemy Turn Ends ---")
	StartPlayerTurn()

func EndGame(player_won: bool):
	HideUI()
	
	if player_won == true:
		for unit in PlayerUnits:
			unit.Data.LevelUp()
		GameData.ClearLevel()
		SaveManager.Save()
	
	get_tree().paused = true
	EndScreen.ShowEndScreen(player_won)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_confirm_pressed():
	if not CurrentGameState == GameState.PLAYER_TURN:
		return
	
	var selected_tile = MyCursor.TilePosition
	
	match CurrentSubState:
		SubState.UNIT_SELECTION_PHASE:
			var unit_on_tile = GetUnitAtTile(selected_tile)
			if unit_on_tile in PlayerUnits and not unit_on_tile in UnitsWhoHaveActed:
				HideUI()
				SetActiveUnit(unit_on_tile)
				ActiveUnitInfoPanel.UpdatePanel(ActiveUnit)
				MyActionMenu.ShowMenu(ActiveUnit)
				CurrentSubState = SubState.ACTION_SELECTION_PHASE
		
		SubState.ACTION_SELECTION_PHASE:
			MyActionMenu.SelectAction()
		
		SubState.TARGETING_PHASE:
			var target = null
			# Check for Move action
			if MyActionManager.HighlightedMoveTiles.has(selected_tile):
				target = selected_tile
				MyActionManager.ClearHighlights()
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, target) == true:
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, target)
				# OnPlayerActionFinished() is called by a tween in MoveAction's _execute
				return
			
			# Check for Attack/Heal action
			var unit_on_tile = GetUnitAtTile(selected_tile)
			if unit_on_tile:
				if MyActionManager.HighlightedAttackTiles.has(selected_tile) or MyActionManager.HighlightedHealTiles.has(selected_tile):
					target = unit_on_tile
			
			if target is Unit:
				TargetedUnit = target
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, target) == true:
					await MyActionManager.PreviewAction(CurrentAction, ActiveUnit, TargetedUnit, true)
					CurrentSubState = SubState.ACTION_CONFIRMATION_PHASE
		
		SubState.ACTION_CONFIRMATION_PHASE:
			ActionForecast.hide()
			HideUI()
			MyActionManager.ClearHighlights()
			
			if selected_tile == GroundGrid.local_to_map(TargetedUnit.global_position):
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, TargetedUnit) == true:
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, TargetedUnit)
					UpdateCursor()
					EndPlayerTurn()

func _on_cancel_pressed():
	if not CurrentGameState == GameState.PLAYER_TURN:
		return
	
	match CurrentSubState:
		SubState.ACTION_SELECTION_PHASE:
			HideUI()
			if ActiveUnit.HasMoved and not ActiveUnit.HasActed:
				var original_global_pos = GroundGrid.to_global(GroundGrid.map_to_local(OriginalUnitTile))
				ActiveUnit.global_position = original_global_pos
				ActiveUnit.HasMoved = false
				UpdateCursor(OriginalUnitTile)
				
			UpdateCursor()
			ClearActiveUnit()
			CurrentSubState = SubState.UNIT_SELECTION_PHASE
		
		SubState.TARGETING_PHASE:
			HideUI()
			MyActionManager.ClearHighlights()
			MyActionMenu.ShowMenu(ActiveUnit)
			CurrentAction = null
			CurrentSubState = SubState.ACTION_SELECTION_PHASE
		
		SubState.ACTION_CONFIRMATION_PHASE:
			ActionForecast.hide()
			MyActionManager.ClearHighlights()
			TargetedUnit = null
			CurrentAction = null
			MyActionMenu.ShowMenu(ActiveUnit)
			CurrentSubState = SubState.ACTION_SELECTION_PHASE

func _on_info_pressed():
	if not (CurrentSubState == SubState.UNIT_SELECTION_PHASE or CurrentSubState == SubState.TARGETING_PHASE):
		return
	
	var unit_on_tile = GetUnitAtTile(MyCursor.TilePosition)
	if unit_on_tile:
		InfoScreen.ShowScreen(unit_on_tile, 0)

func _on_start_pressed():
	if CurrentGameState != GameState.ENEMY_TURN and CurrentSubState != SubState.PROCESSING_PHASE:
		InfoScreen.ShowScreen(null, 2)

func on_trigger_pressed(direction : int):
	if CurrentSubState != SubState.UNIT_SELECTION_PHASE and CurrentSubState != SubState.TARGETING_PHASE:
		return
	
	var unit_on_tile = GetUnitAtTile(MyCursor.TilePosition)
	var next_unit: Unit = null
	
	if unit_on_tile == null:
		next_unit = AllUnits[0]
		UpdateCursor(GroundGrid.local_to_map(next_unit.global_position))
		return
	
	var current_index = AllUnits.find(unit_on_tile)
	var next_index = GeneralFunctions.ClampIndexInArray(current_index, direction, AllUnits)
	next_unit = AllUnits[next_index]
	
	UpdateCursor(GroundGrid.local_to_map(next_unit.global_position))

func _on_direction_pressed(direction: Vector2i):
	match CurrentSubState:
		# We only want the cursor to move in specific phases.
		SubState.UNIT_SELECTION_PHASE, SubState.TARGETING_PHASE:
			var new_position = MyCursor.TilePosition + direction
			UpdateCursor(new_position)
		
		SubState.ACTION_SELECTION_PHASE:
			if direction.y == 1:
				MyActionMenu.NavigateDown()
			elif direction.y == -1:
				MyActionMenu.NavigateUp()
			return

func _on_action_menu_action_selected(action: Action) -> void:
	HideUI()
	action._on_select(ActiveUnit, self)

func _on_spawn_requested(spawn_array: Array[SpawnInfo]):
	SpawnUnitGroup(spawn_array)

func _on_unit_died(unit: Unit):
	if unit in PlayerUnits:
		PlayerUnits.erase(unit)
	elif unit in EnemyUnits:
		EnemyUnits.erase(unit)
	AllUnits = PlayerUnits + EnemyUnits
	
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

func _ready() -> void:
	if not GameData.SelectedLevelScene:
		push_warning("GameData is empty. Loading default Level for testing.")
		GameData.SelectedLevelScene = GameData.TestLevel
		var character_data = GameData.TestCharacter
		GameData.PlayerUnits.clear()
		GameData.PlayerUnits.append(character_data)
	
	SetLevel()
	SetAuxiliaryManagers()
	
	DefinePlayerUnits()
	SpawnStartingUnits()
	
	SetInfoScreen()
	SetCursor()
	SetAudio()
	
	ConnectInputSignals()
	
	level_set.emit()
	StartPlayerTurn()
