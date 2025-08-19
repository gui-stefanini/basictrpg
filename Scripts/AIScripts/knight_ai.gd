class_name KnightAI
extends AIBehavior

func execute_turn(owner: Unit, manager: GameManager):
	print(owner.name + " is thinking like a Knight...")
	
	var health_percentage = float(owner.CurrentHP) / owner.Data.MaxHP
	if health_percentage <= 0.4:
		await DefendCommand(owner, manager)
		return
	
	await execute_offensive_routine(owner, manager)
