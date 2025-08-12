class_name DefendAction
extends Action

func _execute(user: Unit, target = null):
	print(user.name + " is defending!")
	user.HasActed = true
	user.ActiveStatuses[Unit.Status.DEFENDING] = 1
	var map = user.get_tree().current_scene
	map.OnPlayerActionFinished()
