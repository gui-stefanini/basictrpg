class_name Action
extends Resource

@export var Name: String = "Action"

func connect_listeners(_owner: Unit):
	pass

func _on_select(_user: Unit):
	pass # Child scripts will implement their own logic here.

func _execute(_user: Unit, _target = null):
	pass
