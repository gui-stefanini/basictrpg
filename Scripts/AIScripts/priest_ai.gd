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
	
	if IsMobile == false:
		await execute_healing_routine(owner, manager)
		if owner.HasActed == true:
			IsMobile = true
			return
		
		print(owner.Data.Name + " found no one to heal, and will attack instead.")
		await execute_offensive_routine(owner, manager)
		if owner.HasActed == true:
			IsMobile = true
		return
	
	await execute_move_healing_routine(owner, manager)
	if owner.HasActed == true:
		return
	
	print(owner.Data.Name + " found no one to heal, and will attack instead.")
	if owner.HasMoved == true:
		await execute_offensive_routine(owner, manager)
		return
	
	await execute_move_offensive_routine(owner, manager)
	

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
