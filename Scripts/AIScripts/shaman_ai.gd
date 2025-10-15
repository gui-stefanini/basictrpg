class_name ShamanAI
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

func Initialize(ai : AI):
	ai.BehaviorSpecific["turns since summon"] = 2

func execute_turn(owner: Unit, manager: GameManager):
	print(owner.Data.Name + " is thinking like a Shaman...")
	var ai = owner.MyAI
	var move_action : Action = owner.Data.AIActions["Move"]
	var debuff_action : Action = owner.Data.AIActions["Debuff"]
	var summon_action : Action = owner.Data.AIActions["Summon"]
	
	if ai.BehaviorSpecific["turns since summon"] >= 2:
		await ActionCommand(summon_action, owner, manager)
		ai.BehaviorSpecific["turns since summon"] = 0
		return
	
	await ExecuteOffensiveLogic(move_action, debuff_action, owner, manager, ai)
	ai.BehaviorSpecific["turns since summon"] += 1

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
