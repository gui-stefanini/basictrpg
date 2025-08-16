class_name DefendAction
extends Action

func connect_listeners(owner: Unit):
	owner.damage_taken.connect(_on_damage_taken)

func _on_select(user: Unit, manager: Node2D):
	_execute(user, manager)

func _execute(user: Unit, manager: Node2D, _target = null) -> Variant:
	print(user.name + " is defending!")
	user.HasActed = true
	user.ActiveStatuses[Unit.Status.DEFENDING] = 1
	
	if user in manager.PlayerUnits:
		manager.OnPlayerActionFinished()
	
	return null

func _on_damage_taken(unit: Unit, damage_data: Dictionary):
	if unit.ActiveStatuses.has(Unit.Status.DEFENDING):
		print("Defense applied! Damage halved.")
		damage_data["damage"] = round(damage_data["damage"] / 2.0)
