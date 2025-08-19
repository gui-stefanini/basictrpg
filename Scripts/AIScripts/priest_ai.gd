class_name PriestAI
extends AIBehavior

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
	
	await execute_complex_healing_routine(owner, manager)
	if owner.HasActed == true:
		return
	
	var allies = GetValidTargets(owner, manager, manager.EnemyUnits)
	if not allies.is_empty():
		var damaged_allies = []
		
		for ally in allies:
			var unit = ally["target"]
			if unit != owner and unit.CurrentHP < unit.Data.MaxHP:
				damaged_allies.append(ally)
		
		if not damaged_allies.is_empty():
			await execute_healing_routine(owner, manager)
			return
	
	print(owner.name + " found no one to heal, and will attack instead.")
	await execute_offensive_routine(owner, manager)
