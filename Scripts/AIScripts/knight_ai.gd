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
	
	if owner.HPPercent <= 0.4:
		var rand = GeneralFunctions.RandomizeInt(1, 100)
		if rand <= 66:
			await DefendCommand(owner, manager)
			return
	
	if IsMobile == false:
		await execute_offensive_routine(owner, manager)
		if owner.HasActed == true:
			IsMobile = true
		return
	
	await execute_move_offensive_routine(owner, manager)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
