class_name LevelManager
extends Node

@warning_ignore("unused_signal")
signal victory
@warning_ignore("unused_signal")
signal defeat

@export var LevelHighlightLayer: TileMapLayer
var PlayerUnits: Array[Unit]
var EnemyUnits: Array[Unit]

func _on_level_set():
	pass

func _on_unit_died(_unit: Unit):
	pass

func _on_unit_turn_ended(_unit: Unit, _unit_tile: Vector2i):
	pass
