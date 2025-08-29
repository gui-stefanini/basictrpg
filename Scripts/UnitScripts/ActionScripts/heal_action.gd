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

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.SubState.TARGETING_PHASE
	manager.MyActionManager.HighlightHealArea(user, user.AttackRange)
	manager.MyCursor.show()

func _check_target(user: Unit, target = null) -> bool:
	if target is not Unit or target.Faction != user.Faction:
		return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	
	if not _simulation:
		await user.PlayActionAnimation("heal", target)
		
	target.ReceiveHealing(user.HealPower)
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
