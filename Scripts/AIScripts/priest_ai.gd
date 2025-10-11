class_name PriestAI
extends AIBehavior
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

func execute_turn(owner: Unit, manager: GameManager):
	print(owner.Data.Name + " is thinking like a Priest...")
	var ai = owner.MyAI
	var move_action : Action = owner.Data.AIActions["Move"]
	var attack_action : Action = owner.Data.AIActions["Attack"]
	var heal_action : Action = owner.Data.AIActions["Heal"]
	
	await ExecuteSupportLogic(move_action, attack_action, heal_action, owner, manager, ai)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
