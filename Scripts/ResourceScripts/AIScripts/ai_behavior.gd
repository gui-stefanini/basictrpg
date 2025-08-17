class_name AIBehavior
extends Resource

func OffensiveMovementCommand(owner: Unit, manager: Node2D):
	var possible_targets = []
	for player in manager.PlayerUnits:
		var attack_tiles = manager.GetValidAttackTiles(owner, player)
		for tile in attack_tiles:
			var path = manager.FindPath(owner, manager.GroundGrid.local_to_map(owner.global_position), tile)
			if not path.is_empty():
				var cost = manager.GetPathCost(owner, path)
				var target = {
					"target": player,
					"destination": tile,
					"path": path,
					"cost": cost
				}
				possible_targets.append(target)
	
	if possible_targets.is_empty():
		print("No possible target")
		return
	
	possible_targets.sort_custom(func(a, b): 
		return a.cost < b.cost
		)
	
	var best_target = possible_targets[0]
	var target_player = best_target["target"]
	var path_to_destination = best_target["path"]
	print(target_player)
	
	var path_within_move_range: Array[Vector2i] = []
	
	var enemy_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var reachable_tiles = manager.GetReachableTiles(owner, enemy_tile)
	
	for tile in path_to_destination:
		if tile == enemy_tile:
			continue
		if tile in reachable_tiles:
			path_within_move_range.append(tile)
		else:
			break
	
	var final_destination = enemy_tile
	if not path_within_move_range.is_empty():
		final_destination = path_within_move_range.back()
		if final_destination != enemy_tile:
			for action in owner.Data.Actions:
				if action is MoveAction:
					var move_tween = action._execute(owner, manager, final_destination)
					if move_tween is Tween:
						await move_tween.finished

func AttackCommand(owner: Unit, manager: Node2D):
	if owner.HasActed == true:
		return
	
	var unit_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var possible_targets : Array[Unit] = []
	for target in manager.PlayerUnits:
		var target_tile = manager.GroundGrid.local_to_map(target.global_position)
		if manager.AreTilesInRange(owner.Data.AttackRange, unit_tile, target_tile):
			possible_targets.append(target)
	if possible_targets.is_empty():
		print("No target in attack range")
	else:
		var target : Unit = possible_targets.pick_random()
		print("%s chooses to attack %s" % [owner.name, target.name])
		for action in owner.Data.Actions:
			if action is AttackAction:
				await manager.Wait(0.5)
				action._execute(owner, manager, target)
				await manager.Wait(0.5)

func execute_offensive_routine(owner: Unit, manager: Node2D):
	await AttackCommand(owner, manager)
	if owner.HasActed == true:
		return
	await OffensiveMovementCommand(owner, manager)
	await AttackCommand(owner, manager)

# This is the "brain" function. It takes the unit that owns the AI (owner)
# and a reference to the main manager script to access its helper functions.
# It needs to be async so it can wait for animations.
func execute_turn(owner: Unit, _manager: Node2D):
	# Await is needed for the function to be async.
	await owner.get_tree().create_timer(0.01).timeout
	pass
