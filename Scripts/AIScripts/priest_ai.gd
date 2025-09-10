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
	var ai = owner.MyAI
	print(owner.Data.Name + " is thinking like a Priest...")
	
	if ai.IsMobile == false:
		await ExecuteHealingRoutine(owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
			return
		print(owner.Data.Name + " found no one to heal, and will attack instead.")
		await ExecuteOffensiveRoutine(owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
		return
	
	if not ai.TargetTiles.is_empty():
		if not ai.IgnorePlayers:
			await ExecuteHealingRoutine(owner, manager)
			if owner.HasActed == true:
				return
			print(owner.Data.Name + " found no one to heal, and will attack instead.")
			await ExecuteOffensiveRoutine(owner, manager)
			if owner.HasActed == true:
				return
		
		await TileMovementRoutine(owner, manager, owner.TargetTiles)
		return
	
	await ExecuteMoveHealingRoutine(owner, manager)
	if owner.HasActed == true:
		return
	print(owner.Data.Name + " found no one to heal, and will attack instead.")
	if owner.HasMoved == true:
		await ExecuteOffensiveRoutine(owner, manager)
		return
	await ExecuteMoveOffensiveRoutine(owner, manager)
	

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
