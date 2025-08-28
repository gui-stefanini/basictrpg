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

func _execute(user: Unit, manager: GameManager, target = null, simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	if target is not Unit:
		print(str(self) + "has an invalid target type")
		return null
	
	print(user.name + " attacks " + target.name + "!")
	
	var damage = user.AttackPower
	
	if simulation == false:
		var final_damage = await manager.MyActionManager.PreviewAction(self, user, target)
		var combat_scene = manager.CombatScreenScene.instantiate()
		manager.add_child(combat_scene)
		combat_scene.StartCombat(user, target, final_damage)
		await combat_scene.combat_finished
	
	print("Combat finished, apllying damage")
	target.TakeDamage(damage)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
