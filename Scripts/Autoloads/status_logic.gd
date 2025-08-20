extends Node

func ConnectToDamageTaken(unit: Unit, logic: Callable):
	unit.damage_taken.connect(logic)

func DisconnectFromDamageTaken(unit: Unit, logic: Callable):
	if unit.damage_taken.is_connected(logic):
		unit.damage_taken.disconnect(logic)

func ApplyDefendingLogic(unit: Unit, remove: bool = false):
	if remove == true:
		DisconnectFromDamageTaken(unit, Callable(self, _defend_dmgtaken()))
		return
	ConnectToDamageTaken(unit, Callable(self, _defend_dmgtaken()))


func _defend_dmgtaken(unit: Unit, damage_data: Dictionary):
	if unit.ActiveStatuses.has(Unit.Status.DEFENDING):
		print("Defense applied! Damage halved.")
		damage_data["damage"] = round(damage_data["damage"] / 2.0)
