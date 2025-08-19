extends Control

@export var MyProgressBar : ProgressBar

func update_health(current_hp: int, max_hp: int):
	MyProgressBar.max_value = max_hp
	MyProgressBar.value = current_hp

	var percentage = float(current_hp) / max_hp
	if percentage <= 0.25:
		MyProgressBar.get_theme_stylebox("fill").bg_color = Color.RED
	elif percentage <= 0.5:
		MyProgressBar.get_theme_stylebox("fill").bg_color = Color.ORANGE
	else:
		MyProgressBar.get_theme_stylebox("fill").bg_color = Color.LIME_GREEN

func _ready():
	MyProgressBar.add_theme_stylebox_override("fill", MyProgressBar.get_theme_stylebox("fill").duplicate())
