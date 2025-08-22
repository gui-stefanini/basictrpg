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
signal request_spawn(spawn_array: Array[SpawnInfo])

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var LevelHighlightLayer: TileMapLayer
@export var PlayerReinforcements: Array[SpawnInfo]
@export var EnemyReinforcements: Array[SpawnInfo]

######################
#     SCRIPT-WIDE    #
######################
var PlayerUnits: Array[Unit]
var EnemyUnits: Array[Unit]

##############################################################
#                      2.0 Functions                         #
##############################################################

func initialize(game_manager: GameManager):
	victory.connect(game_manager.EndGame.bind(true))
	defeat.connect(game_manager.EndGame.bind(false))
	request_spawn.connect(game_manager._on_spawn_requested)
	
	game_manager.level_set.connect(_on_level_set)
	game_manager.turn_started.connect(_on_turn_started)
	game_manager.turn_ended.connect(_on_turn_ended)
	game_manager.unit_turn_ended.connect(_on_unit_turn_ended)
	game_manager.unit_died.connect(_on_unit_died)
	game_manager.unit_spawned.connect(_on_unit_spawned)
	game_manager.unit_removed.connect(_on_unit_removed)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_level_set():
	pass

func _on_turn_started(_turn_number: int):
	pass

func _on_turn_ended(_turn_number: int):
	pass

func _on_unit_turn_ended(_unit: Unit, _unit_tile: Vector2i):
	pass

func _on_unit_spawned(unit: Unit):
	if unit.Faction == Unit.Factions.PLAYER:
		PlayerUnits.append(unit)
	elif unit.Faction == Unit.Factions.ENEMY:
		EnemyUnits.append(unit)

func _on_unit_died(_unit: Unit):
	pass

func _on_unit_removed(unit: Unit):
	if unit in PlayerUnits:
		PlayerUnits.erase(unit)
	elif unit in EnemyUnits:
		EnemyUnits.erase(unit)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
