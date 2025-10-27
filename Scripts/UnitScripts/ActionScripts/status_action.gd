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
		SelectSelf(user, manager, ActionManager.HighlightTypes.SUPPORT)
		return
	
	if Debuff == true:
		SelectSingleTarget(user, manager, ActionManager.HighlightTypes.ATTACK)
	else:
		SelectSingleTarget(user, manager, ActionManager.HighlightTypes.SUPPORT)

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	var hostile: bool = Debuff
	return CheckUnit(user, target, hostile)

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
