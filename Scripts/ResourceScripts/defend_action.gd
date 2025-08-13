class_name DefendAction
extends Action

func connect_listeners(owner: Unit):
	owner.damage_taken.connect(_on_damage_taken)

func _on_select(user: Unit):
	_execute(user)

func _execute(user: Unit, _target = null):
	var map = user.get_tree().current_scene
	print(user.name + " is defending!")
	user.HasActed = true
	user.ActiveStatuses[Unit.Status.DEFENDING] = 1
	map.OnPlayerActionFinished()

func _on_damage_taken(unit: Unit, damage_data: Dictionary):
	if unit.ActiveStatuses.has(Unit.Status.DEFENDING):
		print("Defense applied! Damage halved.")
		damage_data["damage"] /= 2
