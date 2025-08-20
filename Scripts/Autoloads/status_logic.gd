extends Node
##############################################################
#                      1.0  GENERIC                          #
##############################################################

func ApplyStatusLogic(unit: Unit, status: Unit.Status):
	var status_name = Unit.Status.find_key(status)
	call("Apply%sLogic" % [status_name], unit)

func RemoveStatusLogic(unit: Unit, status: Unit.Status):
	var status_name = Unit.Status.find_key(status)
	call("Apply%sLogic" % [status_name], unit, true)

func ConnectToDamageTaken(unit: Unit, logic: Callable):
	if not unit.damage_taken.is_connected(logic):
		unit.damage_taken.connect(logic)

func DisconnectFromDamageTaken(unit: Unit, logic: Callable):
	if unit.damage_taken.is_connected(logic):
		unit.damage_taken.disconnect(logic)

##############################################################
#                      1.1  STATUS LOGIC                     #
##############################################################

######################
#      DEFENDING     #
######################
func ApplyDEFENDINGLogic(unit: Unit, remove: bool = false):
	if remove == true:
		DisconnectFromDamageTaken(unit, Callable(self, "_defend_dmgtaken"))
		return
	ConnectToDamageTaken(unit, Callable(self, "_defend_dmgtaken"))

func _defend_dmgtaken(unit: Unit, damage_data: Dictionary):
	if unit.ActiveStatuses.has(Unit.Status.DEFENDING):
		print("Defense applied! Damage halved.")
		damage_data["damage"] = round(damage_data["damage"] / 2.0)
