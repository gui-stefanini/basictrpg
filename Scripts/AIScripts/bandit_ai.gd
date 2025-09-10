class_name BanditAI
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
	print(owner.Data.Name + " is thinking like a Bandit...")
	
	if ai.IsMobile == false:
		await ExecuteOffensiveRoutine(owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
		return
	
	if not ai.TargetTiles.is_empty():
		if not ai.IgnorePlayers:
			await ExecuteOffensiveRoutine(owner, manager)
			if owner.HasActed == true:
				return
		
		await TileMovementRoutine(owner, manager, owner.TargetTiles)
		return
	
	await ExecuteMoveOffensiveRoutine(owner, manager)
	

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
