class_name DefendAction
extends Action

func connect_listeners(owner: Unit):
	#owner.damage_taken.connect(_on_damage_taken)
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

#func _on_damage_taken(unit: Unit, damage_data: Dictionary):
	#if unit.ActiveStatuses.has(Unit.Status.DEFENDING):
		#print("Defense applied! Damage halved.")
		#damage_data["damage"] = round(damage_data["damage"] / 2.0)
