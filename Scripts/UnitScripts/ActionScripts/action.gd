class_name Action
extends Resource
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
enum ActionTypes {MOVE, ATTACK, RANDOMATTACK, AOEATTACK, HEAL, STATUS, SUMMON, TERRAIN, WAIT}
@export var Type : ActionTypes

@export var EndTurn : bool = true

enum SelfTargetRule {ONLY, INCLUDE, EXCLUDE}
@export var SelfTarget: SelfTargetRule

@export var Name: String = "Action"
@export var Simulatable: bool = false
@export_multiline var Description: String

@export var AnimationName: String

##############################################################
#                      2.0 Functions                         #
##############################################################

func connect_listeners(_owner: Unit):
	pass

func GetActionRange(_user: Unit) -> int:
	return -1

func SelectSelf(user: Unit, manager: GameManager, highlight: ActionManager.HighlightTypes):
	var action_range = GetActionRange(user)
	manager.MyActionManager.HighlightArea(user, highlight, action_range, true)
	manager.MyCursor.Disable()

func SelectSingleTarget(user: Unit, manager: GameManager, highlight: ActionManager.HighlightTypes):
	var action_range = GetActionRange(user)
	var include_self : bool = false
	if SelfTarget == SelfTargetRule.INCLUDE:
		include_self = true
	
	manager.MyActionManager.HighlightArea(user, highlight, action_range, include_self)
	manager.MyCursor.show()

func SelectAOE(user: Unit, manager: GameManager, highlight: ActionManager.HighlightTypes, aoe_range: int):
	var action_range = GetActionRange(user)
	manager.MyActionManager.HighlightArea(user, highlight, action_range, true)
	manager.MyActionManager.AOERange = aoe_range
	manager.MyCursor.show()

func CheckUnit(user: Unit, target, hostile: bool) -> bool:
	if SelfTarget == SelfTargetRule.ONLY:
		return true
	if target is not Unit:
		return false
	
	if hostile == true:
		var hostile_array : Array[Unit] = UnitManager.GetHostileArray(user)
		if not hostile_array.has(target):
			return false
	else:
		var affiliation_array : Array[Unit] = UnitManager.GetAffiliationArray(user)
		if not affiliation_array.has(target):
			return false
	
	return true

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(_user: Unit, _manager: GameManager):
	pass # Child scripts will implement their own logic here.

func _check_target(_user: Unit, _manager: GameManager = null, _target = null) -> bool:
	return true

func _execute(_user: Unit, _manager: GameManager, _target = null, _simulation : bool = false) -> Variant:
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
