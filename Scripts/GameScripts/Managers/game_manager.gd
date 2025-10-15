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

@export var MyGameCamera: GameCamera

@export var MyActionMenu: ActionMenu

@export var MyCursor: GridCursor

@export var ActiveUnitInfoPanel: PanelContainer
@export var SelectedUnitInfoPanel: PanelContainer
@export var ActionForecast: PanelContainer
@export var MyPreparationMenu: PreparationMenu

@export var DialogueBox: CanvasLayer
@export var InfoScreen: CanvasLayer
@export var EndScreen: CanvasLayer

@export var MyMoveManager: MoveManager
@export var MyActionManager: ActionManager

var CurrentLevel : Level
var CurrentLevelManager: LevelManager
var GroundGrid : TileMapLayer
var EffectLayer: TileMapLayer
var HighlightLayer : TileMapLayer
var CursorHighlightLayer : TileMapLayer

######################
#     SCRIPT-WIDE    #
######################

enum GameState {NULL, PREPARATION, PLAYER_TURN, ALLY_TURN, ENEMY_TURN, WILD_TURN, END}
enum SubState {NULL, UNIT_SELECTION_PHASE, ACTION_SELECTION_PHASE, TARGETING_PHASE, MOVEMENT_PHASE, ACTION_CONFIRMATION_PHASE, PROCESSING_PHASE}
var CurrentGameState : GameState = GameState.NULL
var CurrentSubState : SubState = SubState.NULL

var InactiveUnits: Array[Unit] = []

var TurnNumber: int = 0
var NumberOfUnits : int = 0 #For unit naming

var ActiveUnit: Unit = null
var TargetedUnit: Unit = null
var CurrentAction : Action = null
var OriginalUnitTile: Vector2i

var ChangedTiles: Dictionary = {}

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
	EffectLayer = CurrentLevel.EffectLayer
	HighlightLayer = CurrentLevel.HighlightLayer
	CursorHighlightLayer = CurrentLevel.CursorHighlightLayer

func SetAuxiliaryManagers():
	CurrentLevelManager.Initialize(self)
	MyMoveManager.Initialize(self)
	MyActionManager.Initialize(self)
	MyPreparationMenu.Initialize(self)

func SetCamera():
	MyGameCamera.Initialize(GroundGrid)

func SetHUD():
	InfoScreen.Initialize(self)
	DialogueBox.Initialize(self)

func SetCursor():
	var initial_position : Vector2i = Vector2i(0, 0)
	initial_position = UnitManager.PlayerUnits[0].CurrentTile
	MyCursor.MoveToTile(self, initial_position)

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
	if DialogueBox.visible == true:
		return
	
	var unit_on_tile : Unit = GetUnitAtTile(MyCursor.TilePosition)
	
	if unit_on_tile == null:
		SelectedUnitInfoPanel.UpdatePanel(null)
	
	else:
		SelectedUnitInfoPanel.UpdatePanel(unit_on_tile)

func UpdateCursor(new_tile: Vector2i = Vector2i (-1,-1)):
	if MyCursor.Enabled == false:
		return
	if DialogueBox.visible == true:
		return
	
	if new_tile != Vector2i(-1,-1):
		if MyMoveManager.CheckGridBounds(new_tile) == true:
			MyCursor.MoveToTile(self, new_tile)
			MyGameCamera.CheckCameraEdge(new_tile)
		else:
			var opposite_tile: Vector2i = MyMoveManager.GetOppositeTile(new_tile)
			MyCursor.MoveToTile(self, opposite_tile)
			MyGameCamera.CheckCameraEdge(opposite_tile)
	
	if not MyActionManager.HighlightedAOETiles.is_empty():
		MyActionManager.UpdateAOE(new_tile)
	
	DisplaySelectedUnitInfo()
	MyCursor.show()

func GetUnitAtTile(tile: Vector2i) -> Unit:
	for unit in UnitManager.AllUnits:
		if unit.CurrentTile == tile:
			return unit
	return null

##############################################################
#                      2.3 SPAWNING                          #
##############################################################

func FindClosestValidSpawn(start_tile: Vector2i, invalid_tiles: Array[Vector2i], unit_data: CharacterData) -> Vector2i:
	var move_data_name: String 
	
	if unit_data.MovementType != null:
		move_data_name = unit_data.MovementType.Name
	elif unit_data.CharacterMovementType != null:
		move_data_name = unit_data.CharacterMovementType.Name
	else:
		move_data_name = unit_data.Class.ClassMovementType.Name
	
	var astar = MyMoveManager.AStarInstances[move_data_name]
	
	var check_queue: Array[Vector2i] = [start_tile]
	var queued: Array[Vector2i] = [start_tile]
	
	while not check_queue.is_empty():
		var current_tile = check_queue.pop_front()
		
		var point_id = MyMoveManager.VectorToId(current_tile)
		if astar.has_point(point_id) and not astar.is_point_disabled(point_id) and not invalid_tiles.has(current_tile):
			return current_tile
		
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		directions.shuffle()
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
	
	if spawn_info.Faction != Unit.Factions.PLAYER and spawn_info.Faction != Unit.Factions.PLAYER_SUMMON:
		new_unit.MyAI.SetBehavior(spawn_info.Behavior)
	
	if new_unit.Data.Summon == true:
		new_unit.SetData(spawn_info.CharacterLevel, spawn_info.Summoner)
		new_unit.SetInactive()
		if new_unit.Faction == Unit.Factions.PLAYER_SUMMON:
			InactiveUnits.append(new_unit)
	else:
		new_unit.SetData(spawn_info.CharacterLevel)
	
	new_unit.name = "%s %s %d" % [Unit.Factions.find_key(spawn_info.Faction)[0], unit_data.Name, NumberOfUnits]
	NumberOfUnits += 1
	add_child(new_unit)
	
	UnitManager.AddUnit(new_unit)
	
	var invalid_tiles = MyMoveManager.GetInvalidTiles(unit_data)
	if invalid_tiles.has(spawn_pos):
		spawn_pos = FindClosestValidSpawn(spawn_pos, invalid_tiles, unit_data)
	var tile_grid_position = GroundGrid.map_to_local(spawn_pos)
	var tile_global_position = GroundGrid.to_global(tile_grid_position)
	new_unit.global_position = tile_global_position
	
	new_unit.CurrentTile = spawn_pos
	
	new_unit.turn_started.connect(_on_unit_turn_started)
	new_unit.unit_died.connect(_on_unit_died)
	new_unit.vfx_requested.connect(_on_vfx_requested)
	unit_spawned.emit(new_unit)
	if CurrentLevelManager != null:
		if TurnNumber >= 1:
			await CurrentLevelManager.unit_spawned_completed

func SpawnUnitGroup(spawn_list: Array[SpawnInfo]):
	for spawn_info in spawn_list:
		await SpawnUnit(spawn_info)

func DefinePlayerUnits():
	GameData.PlayerSquad = MyPreparationMenu.SelectedUnits
	
	var smaller_array_size : int = min(GameData.PlayerSquad.size(), CurrentLevel.PlayerSpawns.size())
	
	for i in range(smaller_array_size):
		CurrentLevel.PlayerSpawns[i].Character = GameData.PlayerSquad[i]
	
	var player_spawns: Array[SpawnInfo]
	for player_spawn in CurrentLevel.PlayerSpawns:
		if player_spawn.Character != null:
			player_spawns.append(player_spawn)
	
	SpawnUnitGroup(player_spawns)

func SpawnStartingUnits():
	SpawnUnitGroup(CurrentLevel.AllySpawns)
	SpawnUnitGroup(CurrentLevel.EnemySpawns)
	SpawnUnitGroup(CurrentLevel.WildSpawns)

##############################################################
#                      2.4 GAME FLOW                         #
##############################################################

func SetActiveUnit(unit: Unit):
	ActiveUnit = unit
	OriginalUnitTile = unit.CurrentTile
	ActiveUnit.PlayIdleAnimation()

func ClearActiveUnit():
	ActiveUnit = null
	OriginalUnitTile = Vector2i (-1,-1)

func StartPreparation():
	CurrentGameState = GameState.PREPARATION
	MyPreparationMenu.ShowScreen()

func StartGame():
	await DefinePlayerUnits()
	SetCursor()
	level_set.emit()
	StartNewTurn()

func StartNewTurn():
	CurrentGameState = GameState.PLAYER_TURN
	CurrentSubState = SubState.PROCESSING_PHASE
	print("New turn begins.")
	TurnNumber += 1
	turn_started.emit(TurnNumber)
	await CurrentLevelManager.turn_started_completed
	
	if not ChangedTiles.is_empty():
		var tiles_to_remove: Array[Vector2i] = []
		
		for tile in ChangedTiles:
			if ChangedTiles[tile] > 0:
				ChangedTiles[tile] -= 1
			if ChangedTiles[tile] == 0:
				tiles_to_remove.append(tile)
		
		for tile in tiles_to_remove:
			EffectLayer.erase_cell(tile)
			ChangedTiles.erase(tile)
	
	StartPlayerTurn()

func StartPlayerTurn():
	CurrentSubState = SubState.UNIT_SELECTION_PHASE
	print("Player turn begins.")
	InactiveUnits.clear()
	for unit in UnitManager.CompletePlayerUnits:
		unit.StartTurn()
	UpdateCursor()

func OnPlayerUnitActionFinished():
	CurrentSubState = SubState.ACTION_SELECTION_PHASE
	MyActionMenu.ShowMenu(ActiveUnit)
	ActiveUnit.PlayIdleAnimation()
	ActiveUnit.CurrentTile = GetUnitTile(ActiveUnit)

func OnPlayerUnitTurnFinished():
	if not ActiveUnit: return
	ActiveUnit.StopAnimation()
	
	ActiveUnit.CurrentTile = GetUnitTile(ActiveUnit)
	unit_turn_ended.emit(ActiveUnit, ActiveUnit.CurrentTile)
	await CurrentLevelManager.unit_turn_ended_completed
	
	if CurrentGameState == GameState.END:
		return
	
	InactiveUnits.append(ActiveUnit)
	ActiveUnit.SetInactive()
	ClearActiveUnit()
	
	if InactiveUnits.size() == UnitManager.CompletePlayerUnits.size():
		EndPlayerTurn()
	
	else:
		CurrentSubState = SubState.UNIT_SELECTION_PHASE
		UpdateCursor()

func EndPlayerTurn():
	HideUI()
	for unit in UnitManager.CompletePlayerUnits:
		unit.SetActive()
	await GeneralFunctions.Wait(0.5)
	StartAllyTurn()

func StartAllyTurn():
	print("--- Ally Turn Begins ---")
	CurrentGameState = GameState.ALLY_TURN
	CurrentSubState = SubState.PROCESSING_PHASE
	
	var ally_units : Array[Unit] = UnitManager.CompleteAllyUnits.duplicate()
	
	for unit in ally_units:
		unit.StartTurn()
	
	for unit in ally_units:
		if is_instance_valid(unit):
			await GeneralFunctions.Wait(0.2)
			print(unit.Data.Name + " is taking its turn.")
			await unit.MyAI.Behavior.execute_turn(unit, self)
			unit_turn_ended.emit(unit, unit.CurrentTile)
			await CurrentLevelManager.unit_turn_ended_completed
			unit.SetInactive() 
	
	EndAllyTurn()

func EndAllyTurn():
	print("--- Ally Turn Ends ---")
	for unit in UnitManager.CompleteAllyUnits:
		unit.SetActive()
	await GeneralFunctions.Wait(0.3)
	
	StartEnemyTurn()

func StartEnemyTurn():
	print("--- Enemy Turn Begins ---")
	CurrentGameState = GameState.ENEMY_TURN
	CurrentSubState = SubState.PROCESSING_PHASE
	
	var enemy_units : Array[Unit] = UnitManager.CompleteEnemyUnits.duplicate()
	
	for unit in enemy_units:
		unit.StartTurn()
	
	for unit in enemy_units:
		if is_instance_valid(unit):
			await GeneralFunctions.Wait(0.2)
			print(unit.Data.Name + " is taking its turn.")
			await unit.MyAI.Behavior.execute_turn(unit, self)
			unit_turn_ended.emit(unit, unit.CurrentTile)
			await CurrentLevelManager.unit_turn_ended_completed
			unit.SetInactive() 
	
	EndEnemyTurn()

func EndEnemyTurn():
	print("--- Enemy Turn Ends ---")
	for unit in UnitManager.CompleteEnemyUnits:
		unit.SetActive()
	await GeneralFunctions.Wait(0.3)
	
	StartWildTurn()

func StartWildTurn():
	print("--- Wild Turn Begins ---")
	CurrentGameState = GameState.WILD_TURN
	CurrentSubState = SubState.PROCESSING_PHASE
	
	var wild_units : Array[Unit] = UnitManager.CompleteWildUnits.duplicate()
	
	for unit in wild_units:
		unit.StartTurn()
	
	for unit in wild_units:
		if is_instance_valid(unit):
			await GeneralFunctions.Wait(0.2)
			print(unit.Data.Name + " is taking its turn.")
			await unit.MyAI.Behavior.execute_turn(unit, self)
			unit_turn_ended.emit(unit, unit.CurrentTile)
			await CurrentLevelManager.unit_turn_ended_completed
			unit.SetInactive() 
	
	EndWildTurn()

func EndWildTurn():
	print("--- Wild Turn Ends ---")
	for unit in UnitManager.CompleteWildUnits:
		unit.SetActive()
	await GeneralFunctions.Wait(0.3)
	
	turn_ended.emit(TurnNumber)
	await CurrentLevelManager.turn_ended_completed
	
	StartNewTurn()

func EndGame(player_won: bool):
	HideUI()
	CurrentGameState = GameState.END
	
	if player_won == true:
		for unit in UnitManager.PlayerUnits:
			unit.RequestVFX(VfxList.UnitVFX, "levelup")
			unit.Data.LevelUp()
		GameData.ClearLevel()
		SaveManager.Save()
		await GeneralFunctions.Wait(1.5)
	
	get_tree().paused = true
	EndScreen.ShowEndScreen(player_won)

##############################################################
#                   2.4 DATA GATHERING                       #
##############################################################

func GetTileType(tile: Vector2i) -> String:
	var tile_data = GroundGrid.get_cell_tile_data(tile)
	var effect_tile_data = EffectLayer.get_cell_tile_data(tile)
	var terrain_type: String
	if effect_tile_data:
		terrain_type = effect_tile_data.get_custom_data("terrain_type")
	else:
		terrain_type = tile_data.get_custom_data("terrain_type")
	return terrain_type

func GetUnitTile(unit: Unit) -> Vector2i:
	return GroundGrid.local_to_map(unit.global_position)

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
			if unit_on_tile in UnitManager.CompletePlayerUnits and not unit_on_tile in InactiveUnits:
				HideUI()
				SetActiveUnit(unit_on_tile)
				ActiveUnit.PlayIdleAnimation()
				ActiveUnitInfoPanel.UpdatePanel(ActiveUnit)
				MyActionMenu.ShowMenu(ActiveUnit)
				CurrentSubState = SubState.ACTION_SELECTION_PHASE
		
		SubState.ACTION_SELECTION_PHASE:
			MyActionMenu.SelectAction()
		
		SubState.TARGETING_PHASE:
			ActiveUnit.StopAnimation()
			var target = null
			# Check for Move action
			if MyActionManager.HighlightedMoveTiles.has(selected_tile):
				target = selected_tile
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, target) == true:
					HideUI()
					MyActionManager.ClearHighlights()
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, target)
				return
			
			#Check for AOE action
			if MyActionManager.HighlightedAOETiles.has(selected_tile):
				target = selected_tile
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, target) == true:
					HideUI()
					MyActionManager.ClearHighlights()
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, target)
				return
			
			#Check for cursor-disabling action (actions that use a fixed area)
			if MyCursor.Enabled == false:
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit) == true:
					HideUI()
					MyActionManager.ClearHighlights()
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit)
					MyCursor.Enable()
				return
			
			# Check for Attack/Heal/Status action
			var unit_on_tile = GetUnitAtTile(selected_tile)
			if unit_on_tile:
				if MyActionManager.HighlightedAttackTiles.has(selected_tile) or MyActionManager.HighlightedHealTiles.has(selected_tile):
					target = unit_on_tile
			
			if CurrentAction.Simulatable == false:
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, target) == true:
					HideUI()
					MyActionManager.ClearHighlights()
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, target)
				return
			
			if target is Unit:
				TargetedUnit = target
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, TargetedUnit) == true:
					await MyActionManager.PreviewAction(CurrentAction, ActiveUnit, TargetedUnit, true)
					CurrentSubState = SubState.ACTION_CONFIRMATION_PHASE
		
		SubState.ACTION_CONFIRMATION_PHASE:
			ActionForecast.hide()
			HideUI()
			MyActionManager.ClearHighlights()
			
			if selected_tile == TargetedUnit.CurrentTile:
				if MyActionManager.CheckValidTarget(CurrentAction, ActiveUnit, TargetedUnit) == true:
					HideUI()
					CurrentSubState = SubState.PROCESSING_PHASE
					await MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, TargetedUnit)

func _on_cancel_pressed():
	if not CurrentGameState == GameState.PLAYER_TURN:
		return
	
	match CurrentSubState:
		SubState.ACTION_SELECTION_PHASE:
			HideUI()
			if ActiveUnit.HasMoved and not ActiveUnit.HasActed:
				var original_global_pos = GroundGrid.to_global(GroundGrid.map_to_local(OriginalUnitTile))
				ActiveUnit.global_position = original_global_pos
				ActiveUnit.CurrentTile = OriginalUnitTile
				ActiveUnit.HasMoved = false
				UpdateCursor(OriginalUnitTile)
				
			UpdateCursor()
			ActiveUnit.StopAnimation()
			ClearActiveUnit()
			CurrentSubState = SubState.UNIT_SELECTION_PHASE
		
		SubState.TARGETING_PHASE:
			MyCursor.Enable()
			HideUI()
			MyActionManager.ClearHighlights()
			CurrentAction = null
			MyActionMenu.ShowMenu(ActiveUnit)
			ActiveUnit.PlayIdleAnimation()
			CurrentSubState = SubState.ACTION_SELECTION_PHASE
		
		SubState.ACTION_CONFIRMATION_PHASE:
			ActionForecast.hide()
			MyActionManager.ClearHighlights()
			TargetedUnit = null
			CurrentAction = null
			MyActionMenu.ShowMenu(ActiveUnit)
			ActiveUnit.PlayIdleAnimation()
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
		next_unit = UnitManager.AllUnits[0]
		UpdateCursor(next_unit.CurrentTile)
		return
	
	var current_index = UnitManager.AllUnits.find(unit_on_tile)
	var next_index = GeneralFunctions.ClampIndexInArray(current_index, direction, UnitManager.AllUnits)
	next_unit = UnitManager.AllUnits[next_index]
	
	UpdateCursor(next_unit.CurrentTile)

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
	MyActionManager.SelectAction(action, ActiveUnit)

func _on_spawn_requested(spawn_array: Array[SpawnInfo]):
	SpawnUnitGroup(spawn_array)

func _on_dialogue_requested(text: String):
	HideUI()
	DialogueBox.DisplayText(text)

func _on_unit_turn_started(unit: Unit):
	var unit_tile : Vector2i = unit.CurrentTile
	var tile_data = GroundGrid.get_cell_tile_data(unit_tile)
	var effect_tile_data = EffectLayer.get_cell_tile_data(unit_tile)
	
	var terrain_type: String
	if effect_tile_data != null:
		terrain_type = effect_tile_data.get_custom_data("terrain_type")
	else:
		terrain_type = tile_data.get_custom_data("terrain_type")
	
	TileManager.TurnStartEffect(unit, terrain_type)

func _on_unit_died(unit: Unit):
	UnitManager.RemoveUnit(unit)
	
	unit_removed.emit(unit)
	await CurrentLevelManager.unit_removed_completed
	unit_died.emit(unit)
	await CurrentLevelManager.unit_died_completed
	unit.queue_free()

func _on_vfx_requested(vfx_data: VFXData, animation_name: String, vfx_position: Vector2, is_combat: bool = false):
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
		push_warning("GameData don't have a Selected Level Scene.")
	
	SetLevel()
	SetAuxiliaryManagers()
	
	SpawnStartingUnits()
	
	SetAudio()
	SetHUD()
	SetCamera()
	
	ConnectInputSignals()
	
	StartPreparation()
