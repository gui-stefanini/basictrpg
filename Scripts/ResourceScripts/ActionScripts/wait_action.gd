class_name WaitAction
extends Action

func connect_listeners(_owner):
	pass

func _on_select(user, manager: Node2D):
	_execute(user, manager)

func _execute(_user, manager: Node2D, _target = null) -> Variant:
	manager.EndPlayerTurn()
	return null
