extends Node

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

##############################################################
#                      2.1  TARGET FINDING                   #
##############################################################

func GetValidActionTiles(unit: Unit, manager: GameManager, target: Unit) -> Array[Vector2i]:
	var move_data_name = unit.Data.MovementType.Name
	var astar : AStar2D = manager.MyMoveManager.AStarInstances[move_data_name]
	var valid_tiles: Array[Vector2i] = []
	var target_tile = manager.GroundGrid.local_to_map(target.global_position)
	var tiles_in_range = manager.MyActionManager.GetTilesInRange(target_tile, unit.AttackRange)
	var occupied_tiles = manager.MyMoveManager.GetOccupiedTiles(unit)

	for tile in tiles_in_range:
		if astar.has_point(manager.MyMoveManager.vector_to_id(tile)) and not occupied_tiles.has(tile):
			valid_tiles.append(tile)
	
	return valid_tiles

func GetValidTargets(ai_owner : Unit, manager : GameManager, targets: Array[Unit]) -> Array:
	var valid_targets = []
	for unit in targets:
		if unit == ai_owner:
			continue
		
		var action_tiles = GetValidActionTiles(ai_owner, manager, unit)
		for tile in action_tiles:
			var path = manager.MyMoveManager.FindPath(ai_owner, manager.GroundGrid.local_to_map(ai_owner.global_position), tile)
			if not path.is_empty():
				var target = {
					"target": unit,
					"destination": tile,
					"path": path.path,
					"cost": path.cost
				}
				valid_targets.append(target)
	
	if valid_targets.is_empty():
		print("No possible target")
	
	return valid_targets

func GetTargetsInRange(ai_owner: Unit, manager: GameManager, targets: Array[Unit]):
	var unit_tile = manager.GroundGrid.local_to_map(ai_owner.global_position)
	var possible_targets : Array[Unit] = []
	for target in targets:
		var target_tile = manager.GroundGrid.local_to_map(target.global_position)
		if manager.MyActionManager.AreTilesInRange(ai_owner.AttackRange, unit_tile, target_tile):
			possible_targets.append(target)
	return possible_targets

func GetReachableTargets(ai_owner: Unit, manager: GameManager, targets: Array[Unit]) -> Array:
	var reachable_targets = []
	var ai_owner_tile = manager.GroundGrid.local_to_map(ai_owner.global_position)
	var reachable_tiles = manager.MyMoveManager.GetReachableTiles(ai_owner, ai_owner_tile, true)
	
	for target_unit in targets:
		var tiles_in_attack_range = GetValidActionTiles(ai_owner, manager, target_unit)
		
		var best_destination = null
		var lowest_cost = INF
		
		for attack_tile in tiles_in_attack_range:
			if attack_tile == ai_owner_tile:
				best_destination = ai_owner_tile
				break
			if reachable_tiles.has(attack_tile):
				var path_result = manager.MyMoveManager.FindPath(ai_owner, ai_owner_tile, attack_tile)
				if not path_result.path.is_empty() and path_result.cost < lowest_cost:
					lowest_cost = path_result.cost
					best_destination = attack_tile
		
		if best_destination != null:
			reachable_targets.append({
				"target": target_unit,
				"destination": best_destination,
				"cost": lowest_cost
			})
	
	reachable_targets.sort_custom(func(a, b): return a.cost < b.cost)
	
	return reachable_targets

##############################################################
#                      2.2 TARGET SELECTION                  #
##############################################################

func FilterTargetsByStat(targets: Array[Unit], stat_getter: Callable, highest: bool = false) -> Array[Unit]:
	targets.sort_custom(
		func(a, b):
			var stat_a = stat_getter.call(a)
			var stat_b = stat_getter.call(b)
			if highest == true:
				return stat_a > stat_b
			return stat_a < stat_b
	)
	var best_stat_value = stat_getter.call(targets[0])
	var best_targets: Array[Unit] = []
	
	for target in targets:
		print("Filter checking " + str(target.Data.Name))
		print(str(stat_getter.call(target)))
		if stat_getter.call(target) == best_stat_value:
			best_targets.append(target)
		else:
			# Since the list is sorted, we can stop as soon as the value changes.
			break
	
	return best_targets

func TargetByStat(targets: Array[Unit], stat_getter: Callable, highest: bool = false, random: bool = false) -> Unit:
	targets.sort_custom(
		func(a, b):
			var stat_a = stat_getter.call(a)
			var stat_b = stat_getter.call(b)
			if highest == true:
				return stat_a > stat_b
			return stat_a < stat_b
	)
	
	if random:
		var target_stat_value = stat_getter.call(targets[0])
		var best_targets: Array[Unit] = []
		
		for target in targets:
			if stat_getter.call(target) == target_stat_value:
				best_targets.append(target)
			else:
				break
		
		return best_targets.pick_random()
	
	return targets[0]

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
