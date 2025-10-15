class_name StatusAction
extends Action
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

@export var AnimationName : String

@export var Debuff: bool
@export var RangeModifier: int

@export var Status: Unit.Status
@export var StackDuration: bool
@export var Duration: int
@export var StackValue: bool
@export var Value: int


##############################################################
#                      2.0 Functions                         #
##############################################################

func GetActionRange(user: Unit) -> int:
	return user.AttackRange + RangeModifier

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	if SelfTarget == SelfTargetRule.ONLY:
		manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.SUPPORT, 0, true)
		manager.MyCursor.Disable()
		#manager.MyActionManager.ExecuteAction(self, user)
		return
	
	var action_range = user.AttackRange + RangeModifier
	
	if Debuff == true:
		manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.ATTACK, action_range)
	else:
		var include_self : bool = false
		if SelfTarget == SelfTargetRule.INCLUDE:
			include_self = true
		manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.SUPPORT, 
											  action_range, include_self)
	
	manager.MyCursor.show()

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	if SelfTarget == SelfTargetRule.ONLY:
		return true
	
	if target is not Unit:
		return false
	
	if Debuff == true:
		var hostile_array : Array[Unit] = UnitManager.GetHostileArray(user)
		if not hostile_array.has(target):
			return false
	else:
		var affiliation_array : Array[Unit] = UnitManager.GetAffiliationArray(user)
		if not affiliation_array.has(target):
			return false
	
	return true

func _execute(user: Unit, _manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	print(user.Data.Name + " is using a status action!")
	if SelfTarget == SelfTargetRule.ONLY:
		target = user
	
	await user.PlayActionAnimation(AnimationName, target)
	
	target.AddStatus(Status, Duration, Value, StackDuration, StackValue)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
