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
@export var MyMoveManager: MoveManager
@export var MyActionManager: ActionManager

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

func Wait(seconds: float):
	ManagerTimer.wait_time = seconds
	ManagerTimer.start()
	await ManagerTimer.timeout

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

func SetAuxiliaryManagers():
	MyMoveManager.initialize(self)
	MyActionManager.initialize(self)

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
							
							if MyActionManager.HighlightedMoveTiles.has(clicked_tile):
								target = clicked_tile
								MyActionManager.ClearHighlights()
								MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, target)
								return
							
							if MyActionManager.HighlightedAttackTiles.has(clicked_tile):
								for enemy in EnemyUnits:
									var enemy_tile = GroundGrid.local_to_map(enemy.global_position)
									if enemy_tile == clicked_tile:
										target = enemy
										break
										
							if MyActionManager.HighlightedHealTiles.has(clicked_tile):
								for ally in PlayerUnits:
									var ally_tile = GroundGrid.local_to_map(ally.global_position)
									if ally_tile == clicked_tile:
										target = ally
										break
							
							if target is Unit:
								TargetedUnit = target
								MyActionManager.ForecastAction(CurrentAction, ActiveUnit, TargetedUnit)
								CurrentSubState = PlayerTurnState.ACTION_CONFIRMATION_PHASE
								return
							
							else:
								unit_clicked = DisplayClickedUnitInfo(clicked_tile)
								if unit_clicked == false:
									HideUI()
									MyActionManager.ClearHighlights()
									ActionMenu.ShowMenu(ActiveUnit)
									CurrentAction = null
									CurrentSubState = PlayerTurnState.ACTION_SELECTION_PHASE
						
						PlayerTurnState.ACTION_CONFIRMATION_PHASE:
							ActionForecast.hide()
							MyActionManager.ClearHighlights()
							if clicked_tile == GroundGrid.local_to_map(TargetedUnit.global_position):
								MyActionManager.ExecuteAction(CurrentAction, ActiveUnit, TargetedUnit)
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
	
	SpawnPlayerUnits()
	SpawnEnemyUnits()
	
	SetLevelManager()
	level_set.emit()
	SetAuxiliaryManagers()
	
	StartGame()
