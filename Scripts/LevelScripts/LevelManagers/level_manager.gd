class_name LevelManager
extends Node

@warning_ignore("unused_signal")
signal victory
@warning_ignore("unused_signal")
signal defeat
@warning_ignore("unused_signal")
signal request_spawn_unit(spawn_info: SpawnInfo)

@export var LevelHighlightLayer: TileMapLayer
var PlayerUnits: Array[Unit]
var EnemyUnits: Array[Unit]

func _on_level_set():
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
