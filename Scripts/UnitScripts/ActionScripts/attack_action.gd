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

##############################################################
#                      2.0 Functions                         #
##############################################################


##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.SubState.TARGETING_PHASE
	manager.MyActionManager.HighlightAttackArea(user, user.AttackRange)
	manager.MyCursor.show()

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	if target is not Unit or target.Faction == user.Faction:
		return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	
	print(user.Data.Name + " attacks " + target.Data.Name + "!")
	
	var damage = user.AttackPower
	
	if simulation == false:
		var final_damage = await manager.MyActionManager.PreviewAction(self, user, target)
		await manager.MyActionManager.StartCombat(user, target, final_damage)
	
	print("Combat finished, apllying damage")
	target.TakeDamage(damage)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
