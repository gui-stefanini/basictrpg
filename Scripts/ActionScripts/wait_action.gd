class_name WaitAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, manager: GameManager):
	_execute(user, manager)

func _execute(_user: Unit, manager: GameManager, _target = null) -> Variant:
	manager.EndPlayerTurn()
	return null
