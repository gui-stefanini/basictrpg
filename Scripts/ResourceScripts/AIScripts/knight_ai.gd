class_name KnightAI
extends AIBehavior

func execute_turn(owner: Unit, map: Node2D):
	print(owner.name + " is thinking like a Knight...")
	var target_player = map.FindClosestPlayerTo(owner)
	
	if not target_player:
		await map.Wait(0.5)
		return
	
	var enemy_tile = map.GroundGrid.local_to_map(owner.global_position)
	var target_player_tile = map.GroundGrid.local_to_map(target_player.global_position)
	var reachable_tiles = map.GetReachableTiles(owner, enemy_tile, owner.Data.MoveRange)
	var best_destination = map.FindBestDestination(owner, reachable_tiles, target_player_tile)
	
	if best_destination != enemy_tile and best_destination != Vector2i(-1, -1):
		print(owner.name + " chooses to move.")
		for action in owner.Data.Actions:
			if action is MoveAction:
				var move_tween = action._execute(owner, map, best_destination)
				if move_tween is Tween:
					await move_tween.finished
		enemy_tile = best_destination
	
	if map.AreTilesInRange(owner.Data.AttackRange, enemy_tile, target_player_tile):
		print(owner.name + " chooses to attack!")
		for action in owner.Data.Actions:
			if action is AttackAction:
				action._execute(owner, map, target_player)
				await map.Wait(0.5)
