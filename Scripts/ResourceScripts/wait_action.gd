class_name WaitAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit):
	_execute(user)

func _execute(user: Unit, _target = null):
	var map = user.get_tree().current_scene
	map.EndPlayerTurn()
