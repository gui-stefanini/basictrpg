class_name WaitAction
extends Action

func _execute(user: Unit, target = null):
	var map = user.get_tree().current_scene
	map.EndPlayerTurn()
