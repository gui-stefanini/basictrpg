class_name KnightAI
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
	print(owner.Data.Name + " is thinking like a Knight...")
	var ai = owner.MyAI
	var move_action : Action = owner.Data.AIActions["Move"]
	var attack_action : Action = owner.Data.AIActions["Attack"]
	var defend_action : Action = owner.Data.AIActions["Defend"]
	
	if owner.HPPercent <= 0.4:
		var rand = GeneralFunctions.RandomizeInt(1, 100)
		if rand <= 66:
			await ActionCommand(defend_action, owner, manager)
			return
	
	await ExecuteOffensiveLogic(move_action, attack_action, owner, manager, ai)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
