extends Node
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
######################
#     SCRIPT-WIDE    #
######################
##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      2.1  GENERIC                          #
##############################################################

func ApplyStatusLogic(unit: Unit, status: Unit.Status):
	var status_name = Unit.Status.find_key(status)
	call("Apply%sLogic" % [status_name], unit)

func RemoveStatusLogic(unit: Unit, status: Unit.Status):
	var status_name = Unit.Status.find_key(status)
	call("Apply%sLogic" % [status_name], unit, true)

func SetStatusLimit(unit: Unit, status: Unit.Status):
	if unit.ActiveStatuses.has(status):
		var status_data = unit.ActiveStatuses[status]
		var status_name = Unit.Status.find_key(status)
		
		var status_info : Dictionary = call("Get%sLimit" % [status_name])
		var duration = status_info["duration"]
		var value = status_info["value"]
		
		status_data[Unit.StatusInfo.DURATION] = min(status_data[Unit.StatusInfo.DURATION], duration)
		status_data[Unit.StatusInfo.VALUE] = min(status_data[Unit.StatusInfo.VALUE], value)

##############################################################
#                 2.2  SIGNAL CONECTIONS                     #
##############################################################

######################
#     TURN STARTED   #
######################
func ConnectToTurnStarted(unit: Unit, logic: Callable):
	if not unit.turn_started.is_connected(logic):
		unit.turn_started.connect(logic)

func DisconnectFromTurnStarted(unit: Unit, logic: Callable):
	if unit.turn_started.is_connected(logic):
		unit.turn_started.disconnect(logic)

######################
#     DMG TAKEN      #
######################
func ConnectToDamageTaken(unit: Unit, logic: Callable):
	if not unit.damage_taken.is_connected(logic):
		unit.damage_taken.connect(logic)

func DisconnectFromDamageTaken(unit: Unit, logic: Callable):
	if unit.damage_taken.is_connected(logic):
		unit.damage_taken.disconnect(logic)

##############################################################
#                     2.3  STATUS-SPECIFIC                   #
##############################################################

######################
#        PASS        #
######################
func ApplyPASSLogic(_unit: Unit, _remove: bool = false):
	pass

func GetPASSLimit():
	var status_info: Dictionary = {"duration": -1, "value": -1}
	return status_info

######################
#     DEFENDING      #
######################
func ApplyDEFENDINGLogic(unit: Unit, remove: bool = false):
	if remove == true:
		DisconnectFromDamageTaken(unit, Callable(self, "_defend_dmgtaken"))
		return
	ConnectToDamageTaken(unit, Callable(self, "_defend_dmgtaken"))

func _defend_dmgtaken(unit: Unit, damage_data: Dictionary):
	if unit.ActiveStatuses.has(Unit.Status.DEFENDING):
		print("Defense applied! Damage halved.")
		damage_data["damage"] = damage_data["damage"] / 2.0

func GetDEFENDINGLimit() -> Dictionary:
	var status_info: Dictionary = {"duration": 1, "value": -1}
	return status_info


######################
#     REGENERATING   #
######################
func ApplyREGENERATINGLogic(unit: Unit, remove: bool = false):
	if remove == true:
		DisconnectFromTurnStarted(unit, Callable(self, "_regen_turn_started"))
		return
	ConnectToTurnStarted(unit, Callable(self, "_regen_turn_started"))

func _regen_turn_started(unit: Unit):
	if unit.ActiveStatuses.has(Unit.Status.REGENERATING):
		var value: int = unit.ActiveStatuses[Unit.Status.REGENERATING][Unit.StatusInfo.VALUE] * 25
		print("Regen! HP Recovered.")
		unit.ReceiveHealing(value, true)

func GetREGENERATINGLimit() -> Dictionary:
	var status_info: Dictionary = {"duration": 2, "value": 4}
	return status_info

######################
#      POISONED      #
######################
func ApplyPOISONEDLogic(unit: Unit, remove: bool = false):
	if remove == true:
		DisconnectFromTurnStarted(unit, Callable(self, "_poison_turn_started"))
		return
	ConnectToTurnStarted(unit, Callable(self, "_poison_turn_started"))

func _poison_turn_started(unit: Unit):
	if unit.ActiveStatuses.has(Unit.Status.POISONED):
		var value: int = unit.ActiveStatuses[Unit.Status.POISONED][Unit.StatusInfo.VALUE] * 25
		print("Poison! Damage taken.")
		unit.TakeDamage(value, true, true, false)

func GetPOISONEDLimit() -> Dictionary:
	var status_info: Dictionary = {"duration": 2, "value": 4}
	return status_info

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
