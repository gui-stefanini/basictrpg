class_name PriestAI
extends AIBehavior

func execute_turn(owner: Unit, manager: GameManager):
	print(owner.name + " is thinking like a Priest...")
	
	var heal_plan = manager.FindHealOpportunity(owner)
	
	if heal_plan.has("target"):
		var target_ally = heal_plan["target"]
		var destination = heal_plan["destination"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		
		if destination != current_tile:
			for action in owner.Data.Actions:
				if action is MoveAction:
					var move_tween = action._execute(owner, manager, destination)
					if move_tween is Tween:
						await move_tween.finished
					break
		
		for action in owner.Data.Actions:
			if action is HealAction:
				print(owner.name + " heals " + target_ally.name)
				action._execute(owner, manager, target_ally)
				break
		
		await manager.Wait(0.5)
		return
	
	print(owner.name + " found no one to heal, and will attack instead.")
	await execute_offensive_routine(owner, manager)
