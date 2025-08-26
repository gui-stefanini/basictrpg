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
	manager.CurrentSubState = manager.PlayerTurnState.TARGETING_PHASE
	manager.MyActionManager.HighlightHealArea(user, user.AttackRange)

func _execute(user: Unit, _manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	if target is not Unit:
		print(str(self) + "has an invalid target type")
		return null
	
	if not _simulation:
		await user.PlayActionAnimation("heal", target)
		
	target.ReceiveHealing(user.HealPower)
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
