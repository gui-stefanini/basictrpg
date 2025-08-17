class_name KnightAI
extends AIBehavior

func execute_turn(owner: Unit, manager: GameManager):
	print(owner.name + " is thinking like a Knight...")
	
	var health_percentage = float(owner.CurrentHP) / owner.Data.MaxHP
	if health_percentage <= 0.4:
		print(owner.name + " is low on health and chooses to defend!")
		for action in owner.Data.Actions:
			if action is DefendAction:
				action._execute(owner, manager)
				await manager.Wait(0.5)
				return
	
	await execute_offensive_routine(owner, manager)
