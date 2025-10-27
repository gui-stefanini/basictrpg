class_name AttackAction
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

@export var DamageModifier: int
@export var RangeModifier: int

##############################################################
#                      2.0 Functions                         #
##############################################################

func GetActionRange(user: Unit) -> int:
	return user.AttackRange + RangeModifier

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	SelectSingleTarget(user, manager, ActionManager.HighlightTypes.ATTACK)

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	return CheckUnit(user, target, true)

func _execute(user: Unit, manager: GameManager, target = null, simulation : bool = false) -> Variant:
	print(user.Data.Name + " attacks " + target.Data.Name + "!")
	
	var damage = user.AttackPower + DamageModifier
	
	if simulation == false:
		var final_damage = await manager.MyActionManager.PreviewAction(self, user, target)
		await manager.MyActionManager.StartCombat(user, target, final_damage, AnimationName)
	
	print("Combat finished, apllying damage")
	target.TakeDamage(damage)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
