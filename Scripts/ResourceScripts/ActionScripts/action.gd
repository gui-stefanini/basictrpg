class_name Action
extends Resource

@export var Name: String = "Action"
@export_multiline var Description: String = ""

func connect_listeners(_owner):
	pass

func _on_select(_user, _manager: Node2D):
	pass

func _execute(_user, _manager: Node2D, _target = null) -> Variant:
	return null
