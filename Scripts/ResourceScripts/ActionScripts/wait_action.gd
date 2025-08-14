class_name WaitAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, map: Node2D):
	_execute(user, map)

func _execute(_user: Unit, map: Node2D, _target = null):
	map.EndPlayerTurn()
