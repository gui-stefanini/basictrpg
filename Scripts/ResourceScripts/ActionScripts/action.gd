class_name Action
extends Resource

@export var Name: String = "Action"
@export_multiline var Description: String = ""

func connect_listeners(_owner: Unit):
	pass

func _on_select(_user: Unit, _manager: Node2D):
	pass # Child scripts will implement their own logic here.

func _execute(_user: Unit, _manager: Node2D, _target = null) -> Variant:
	return null
