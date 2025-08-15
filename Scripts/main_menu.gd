extends Control

@export var SelectionMenuScene: PackedScene

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(SelectionMenuScene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
