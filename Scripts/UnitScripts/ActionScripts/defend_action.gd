class_name DefendAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, manager: GameManager):
	_execute(user, manager)

func _execute(user: Unit, manager: GameManager, _target = null) -> Variant:
	print(user.name + " is defending!")
	user.HasActed = true
	user.AddStatus(Unit.Status.DEFENDING, 1)
	StatusLogic.ApplyStatusLogic(user, Unit.Status.DEFENDING)
	
	if user in manager.PlayerUnits:
		manager.OnPlayerActionFinished()
	
	return null
