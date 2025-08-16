class_name AIBehavior
extends Resource

func execute_offensive_routine(owner: Unit, manager: Node2D):
	var target_player = manager.FindClosestPlayerTo(owner)
	
	if not target_player:
		print("no target player")
		await manager.Wait(0.5)
		return
	print(target_player)
	
	var enemy_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var target_player_tile = manager.GroundGrid.local_to_map(target_player.global_position)
	
	var optimal_path = manager.FindPath(owner, enemy_tile, target_player_tile)
	if optimal_path.is_empty():
		print(owner.name + " has no path to the target.")
		return
		
	var reachable_tiles = manager.GetReachableTiles(owner, enemy_tile, owner.Data.MoveRange)
	var best_destination = enemy_tile
	#best_destination = manager.FindBestDestination(owner, reachable_tiles, target_player_tile)
	for i in range(optimal_path.size() - 1, 0, -1):
		var path_tile = optimal_path[i]
		if reachable_tiles.has(path_tile):
			best_destination = path_tile
	
	print("best destination is: " + str(best_destination))
	
	if best_destination != enemy_tile:
		print(owner.name + " chooses to move.")
		for action in owner.Data.Actions:
			if action is MoveAction:
				var move_tween = action._execute(owner, manager, best_destination)
				if move_tween is Tween:
					await move_tween.finished
		enemy_tile = best_destination
	
	if manager.AreTilesInRange(owner.Data.AttackRange, enemy_tile, target_player_tile):
		print(owner.name + " chooses to attack!")
		for action in owner.Data.Actions:
			if action is AttackAction:
				await manager.Wait(0.5)
				action._execute(owner, manager, target_player)
				await manager.Wait(0.5)

# This is the "brain" function. It takes the unit that owns the AI (owner)
# and a reference to the main manager script to access its helper functions.
# It needs to be async so it can wait for animations.
func execute_turn(owner: Unit, _manager: Node2D):
	# Await is needed for the function to be async.
	await owner.get_tree().create_timer(0.01).timeout
	pass
