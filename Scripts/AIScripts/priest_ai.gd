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

#func execute_turn(owner: Unit, manager: GameManager):
	#print(owner.name + " is thinking like a Priest...")
	#var allies = GetValidTargets(owner, manager, manager.EnemyUnits)
	#
	#if not allies.is_empty():
		#var damaged_allies = []
		#
		#for ally in allies:
			#var unit = ally["target"]
			#if unit != owner and unit.CurrentHP < unit.Data.MaxHP:
				#damaged_allies.append(ally)
		#
		#if not damaged_allies.is_empty():
			#await execute_healing_routine(owner, manager)
			#return
	#
	#print(owner.name + " found no one to heal, and will attack instead.")
	#await execute_offensive_routine(owner, manager)

func execute_turn(owner: Unit, manager: GameManager):
	print(owner.name + " is thinking like a Priest...")
	
	await execute_move_healing_routine(owner, manager)
	if owner.HasActed == true:
		return
	
	print(owner.name + " found no one to heal, and will attack instead.")
	
	await execute_move_offensive_routine(owner, manager)
	
##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
