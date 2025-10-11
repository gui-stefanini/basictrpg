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

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	if SelfTarget == SelfTargetRule.ONLY:
		manager.MyActionManager.HighlightHealArea(user, 0, true)
		manager.MyCursor.Disable()
		#manager.MyActionManager.ExecuteAction(self, user)
		return
	
	var action_range = user.AttackRange + RangeModifier
	var include_self : bool = false
	if SelfTarget == SelfTargetRule.INCLUDE:
		include_self = true
	
	manager.MyActionManager.HighlightHealArea(user, action_range, include_self)
	manager.MyCursor.show()

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	if target is not Unit:
		return false
	
	var user_friendly: bool = user.Faction in [Unit.Factions.PLAYER, Unit.Factions.ALLY]
	var target_friendly: bool = target.Faction in [Unit.Factions.PLAYER, Unit.Factions.ALLY]
	var opponents: bool = user_friendly != target_friendly
	
	if opponents == true:
		return false
	
	return true

func _execute(user: Unit, _manager: GameManager, target = null, simulation : bool = false) -> Variant:
	if simulation == false:
		await user.PlayActionAnimation("heal", target)
	
	var heal_amount = user.HealPower + HealModifier
	target.ReceiveHealing(heal_amount)
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
