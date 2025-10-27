class_name HealAction
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

@export var HealModifier: int
@export var RangeModifier: int

##############################################################
#                      2.0 Functions                         #
##############################################################

func GetActionRange(user: Unit) -> int:
	if SelfTarget == SelfTargetRule.ONLY:
		return 0
	
	return user.AttackRange + RangeModifier

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	if SelfTarget == SelfTargetRule.ONLY:
		SelectSelf(user, manager, ActionManager.HighlightTypes.SUPPORT)
	
	SelectSingleTarget(user, manager, ActionManager.HighlightTypes.SUPPORT)

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	return CheckUnit(user, target, false)

func _execute(user: Unit, _manager: GameManager, target = null, simulation : bool = false) -> Variant:
	if simulation == false:
		await user.PlayActionAnimation(AnimationName, target)
	
	var heal_amount = user.HealPower + HealModifier
	target.ReceiveHealing(heal_amount)
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
