class_name LevelManager
extends Node
##############################################################
#                      0.0 Signals                           #
##############################################################
@warning_ignore("unused_signal")
signal victory
@warning_ignore("unused_signal")
signal defeat

@warning_ignore("unused_signal")
signal turn_started_completed
@warning_ignore("unused_signal")
signal turn_ended_completed
@warning_ignore("unused_signal")
signal unit_turn_ended_completed
@warning_ignore("unused_signal")
signal unit_spawned_completed
@warning_ignore("unused_signal")
signal unit_died_completed
@warning_ignore("unused_signal")
signal unit_removed_completed

@warning_ignore("unused_signal")
signal request_spawn(spawn_array: Array[SpawnInfo])
@warning_ignore("unused_signal")
signal request_dialogue(text: String)
@warning_ignore("unused_signal")
signal request_vfx(vfx: VFXData, animation_name: String, vfx_position: Vector2)
##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var LevelObjective: String
@export_multiline var LevelDialogue: String
@export var LevelBGM: AudioStream
@export var LevelHighlightLayer: TileMapLayer
@export var LevelVFX : VFXData
@export var PlayerReinforcements: Array[SpawnInfo]
@export var AllyReinforcements: Array[SpawnInfo]
@export var EnemyReinforcements: Array[SpawnInfo]
@export var WildReinforcements: Array[SpawnInfo]

var MyGameManager: GameManager

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func Initialize(game_manager: GameManager):
	MyGameManager = game_manager
	victory.connect(game_manager.EndGame.bind(true))
	defeat.connect(game_manager.EndGame.bind(false))
	request_spawn.connect(game_manager._on_spawn_requested)
	request_dialogue.connect(game_manager._on_dialogue_requested)
	request_vfx.connect(game_manager._on_vfx_requested)
	
	game_manager.level_set.connect(_on_level_set)
	game_manager.turn_started.connect(_on_turn_started)
	game_manager.turn_ended.connect(_on_turn_ended)
	game_manager.unit_turn_ended.connect(_on_unit_turn_ended)
	game_manager.unit_died.connect(_on_unit_died)
	game_manager.unit_spawned.connect(_on_unit_spawned)
	game_manager.unit_removed.connect(_on_unit_removed)

func CallReinforcements(reinforcements: Array[SpawnInfo]):
	request_spawn.emit(reinforcements)

func LevelSet():
	pass

func TurnStarted(_turn_number: int):
	pass

func TurnEnded(_turn_number: int):
	pass

func UnitTurnEnded(_unit: Unit, _unit_tile: Vector2i):
	pass

func UnitSpawned(_unit: Unit):
	pass

func UnitDied(_unit: Unit):
	pass

func UnitRemoved(_unit: Unit):
	pass

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_level_set():
	LevelSet()

func _on_turn_started(turn_number: int):
	await TurnStarted(turn_number)
	emit_signal.call_deferred("turn_started_completed")

func _on_turn_ended(turn_number: int):
	await TurnEnded(turn_number)
	emit_signal.call_deferred("turn_ended_completed")

func _on_unit_turn_ended(unit: Unit, unit_tile: Vector2i):
	await UnitTurnEnded(unit, unit_tile)
	emit_signal.call_deferred("unit_turn_ended_completed")

func _on_unit_spawned(unit: Unit):
	await UnitSpawned(unit)
	emit_signal.call_deferred("unit_spawned_completed")

func _on_unit_died(unit: Unit):
	await UnitDied(unit)
	emit_signal.call_deferred("unit_died_completed")

func _on_unit_removed(unit: Unit):
	await UnitRemoved(unit)
	emit_signal.call_deferred("unit_removed_completed")

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
