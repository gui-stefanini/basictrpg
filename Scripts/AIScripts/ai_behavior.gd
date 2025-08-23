class_name AIBehavior
extends Resource
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
#                      2.1  COMMANDS                         #
##############################################################

func DefendCommand(owner: Unit, manager: GameManager):
	print(owner.name + " is low on health and chooses to defend!")
	for action in owner.Data.Actions:
		if action is DefendAction:
			action._execute(owner, manager)
			await manager.Wait(0.5)

func HealCommand(owner: Unit, manager: GameManager, target: Unit):
	for action in owner.Data.Actions:
		if action is HealAction:
			print(owner.name + " heals " + target.name)
			action._execute(owner, manager, target)
			break
	
	await manager.Wait(0.5)

func MoveCommand(owner: Unit, manager: GameManager, destination: Vector2i):
	for action in owner.Data.Actions:
		if action is MoveAction:
			var move_tween = action._execute(owner, manager, destination)
			if move_tween is Tween:
				await move_tween.finished

func AttackCommand(owner: Unit, manager: GameManager, target: Unit):
		for action in owner.Data.Actions:
			if action is AttackAction:
				await manager.Wait(0.5)
				action._execute(owner, manager, target)
				await manager.Wait(0.5)

##############################################################
#                      2.2  TARGET FINDING                   #
##############################################################

func GetValidActionTiles(unit: Unit, manager: GameManager, target: Unit) -> Array[Vector2i]:
	var move_data_name = unit.Data.MovementType.Name
	var astar : AStar2D = manager.MyMoveManager.AStarInstances[move_data_name]
	var valid_tiles: Array[Vector2i] = []
	var target_tile = manager.GroundGrid.local_to_map(target.global_position)
	var tiles_in_range = manager.MyActionManager.GetTilesInRange(target_tile, unit.Data.AttackRange)
	var occupied_tiles = manager.MyMoveManager.GetOccupiedTiles(unit)

	for tile in tiles_in_range:
		if astar.has_point(manager.MyMoveManager.vector_to_id(tile)) and not occupied_tiles.has(tile):
			valid_tiles.append(tile)
	
	return valid_tiles

func GetValidTargets(owner : Unit, manager : GameManager, targets: Array[Unit]) -> Array:
	var valid_targets = []
	for unit in targets:
		if unit == owner:
			continue
		
		var action_tiles = GetValidActionTiles(owner, manager, unit)
		for tile in action_tiles:
			var path = manager.MyMoveManager.FindPath(owner, manager.GroundGrid.local_to_map(owner.global_position), tile)
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

func GetTargetsInRange(owner: Unit, manager: GameManager, targets: Array[Unit]):
	var unit_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var possible_targets : Array[Unit] = []
	for target in targets:
		var target_tile = manager.GroundGrid.local_to_map(target.global_position)
		if manager.MyActionManager.AreTilesInRange(owner.Data.AttackRange, unit_tile, target_tile):
			possible_targets.append(target)
	return possible_targets

func GetReachableTargets(owner: Unit, manager: GameManager, targets: Array[Unit]) -> Array:
	var reachable_targets = []
	var owner_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var reachable_tiles = manager.MyMoveManager.GetReachableTiles(owner, owner_tile, true)
	
	for target_unit in targets:
		var target_tile = manager.GroundGrid.local_to_map(target_unit.global_position)
		var tiles_in_attack_range = manager.MyActionManager.GetTilesInRange(target_tile, owner.Data.AttackRange)
		
		var best_destination = null
		var lowest_cost = INF
		
		for attack_tile in tiles_in_attack_range:
			if reachable_tiles.has(attack_tile):
				var path_result = manager.MyMoveManager.FindPath(owner, owner_tile, attack_tile)
				if not path_result.path.is_empty() and path_result.cost < lowest_cost:
					lowest_cost = path_result.cost
					best_destination = attack_tile
		
		if best_destination != null:
			reachable_targets.append({
				"target": target_unit,
				"destination": best_destination,
				"cost": lowest_cost
			})
			
	return reachable_targets

##############################################################
#                      2.3 TARGET SELECTION                  #
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

func HealTargeting(owner: Unit, manager: GameManager):
	var possible_targets = GetTargetsInRange(owner, manager, manager.EnemyUnits)
	
	if possible_targets.is_empty():
		print("No target in heal range")
		return null
	else:
		var target = TargetByStat(possible_targets, func(u : Unit): return u.HPPercent)
		#var target = TargetByStat(possible_targets, "HPPercent")
		return target

func AttackTargeting(owner: Unit, manager: GameManager):
	var possible_targets = GetTargetsInRange(owner, manager, manager.PlayerUnits)
	
	if possible_targets.is_empty():
		print("No target in attack range")
		return null
	else:
		var high_aggro_targets = FilterTargetsByStat(possible_targets, func(u: Unit): return u.Data.Aggro, true)
		var target = TargetByStat(high_aggro_targets, func(u:Unit): return u.CurrentHP)
		return target

##############################################################
#                      2.4  AI ROUTINES                      #
##############################################################
######################
#   ROUTINE BLOCKS   #
######################
func HealRoutine(owner: Unit, manager: GameManager):
	var target = HealTargeting(owner, manager)
	if target is Unit:
		print("%s chooses to heal %s" % [owner.name, target.name])
		await HealCommand(owner, manager, target)

func AttackRoutine(owner: Unit, manager: GameManager):
	var target = AttackTargeting(owner, manager)
	if target is Unit:
		print("%s chooses to attack %s" % [owner.name, target.name])
		await AttackCommand(owner, manager, target)

func ActionMovementRoutine(owner: Unit, manager: GameManager, targets: Array[Unit]):
	var valid_targets = GetValidTargets(owner, manager, targets)
	if valid_targets.is_empty():
		print("%s has no valid path to any target." % owner.name)
		return
		
	valid_targets.sort_custom(func(a, b): 
		return a.cost < b.cost
		)
	
	var best_target = valid_targets[0]
	var target_player = best_target["target"]
	var path_to_destination = best_target["path"]
	print(target_player)
	var path_within_move_range: Array[Vector2i] = []
	
	var enemy_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var reachable_tiles = manager.MyMoveManager.GetReachableTiles(owner, enemy_tile)
	
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
			await MoveCommand(owner, manager, final_destination)

func FindHealOpportunity(healer: Unit, manager: GameManager) -> Dictionary:
	var damaged_allies: Array[Unit] = []
	for ally in manager.EnemyUnits: # Make sure this targets the correct faction!
		if ally != healer and ally.CurrentHP < ally.Data.MaxHP:
			damaged_allies.append(ally)
	
	if damaged_allies.is_empty():
		return {}
	
	TargetByStat(damaged_allies, func(u: Unit): return u.HPPercent)
	# Sort allies by the amount of damage taken (most damaged first)
	#damaged_allies.sort_custom(
		#func(a, b):
			#var health_percentage_a = float(a.CurrentHP) / a.Data.MaxHP
			#var health_percentage_b = float(b.CurrentHP) / b.Data.MaxHP
			#return health_percentage_a > health_percentage_b
	#)
	
	var healer_tile = manager.GroundGrid.local_to_map(healer.global_position)
	var reachable_tiles = manager.MyMoveManager.GetReachableTiles(healer, healer_tile, true)
	
	for target_ally in damaged_allies:
		var potential_heal_tiles = GetValidActionTiles(healer, manager, target_ally)
		var best_tile_for_target = null
		var lowest_cost = INF
		
		# Find the cheapest tile to move to for healing this specific ally
		for heal_tile in potential_heal_tiles:
			if heal_tile == healer_tile:
				best_tile_for_target = heal_tile
				break
			if reachable_tiles.has(heal_tile):
				var path_result = manager.MyMoveManager.FindPath(healer, healer_tile, heal_tile)
				if path_result.cost < lowest_cost:
					lowest_cost = path_result.cost
					best_tile_for_target = heal_tile
		
		# If we found a reachable tile for this target, we have our action
		if best_tile_for_target != null:
			print("Found heal opportunity for %s -> %s" % [healer.name, target_ally.name])
			return {
				"target": target_ally,
				"destination": best_tile_for_target
			}
	
	return {} # No reachable, damaged ally found

######################
#    ROUTINE LOGIC   #
######################
func execute_complex_healing_routine(owner: Unit, manager: GameManager):
	var heal_opportunity = FindHealOpportunity(owner, manager)
	if not heal_opportunity.is_empty():
		var destination = heal_opportunity["destination"]
		var target = heal_opportunity["target"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		
		if destination != current_tile:
			await MoveCommand(owner, manager, destination)
		
		await HealCommand(owner, manager, target)

func execute_healing_routine(owner: Unit, manager: GameManager):
	await HealRoutine(owner, manager)
	if owner.HasActed == true:
		return
	await ActionMovementRoutine(owner, manager, manager.EnemyUnits)
	await HealRoutine(owner, manager)

func execute_complex_offensive_routine(owner: Unit, manager: GameManager):
	var reachable_targets = GetReachableTargets(owner, manager, manager.PlayerUnits)
	if reachable_targets.is_empty():
		print("%s cannot reach any target to attack this turn, moving closer." % owner.name)
		await ActionMovementRoutine(owner, manager, manager.PlayerUnits)
	
	else:
		#Creates an array from the key "target" in each dictionary entry
		var target_units: Array[Unit] = []
		for target_data in reachable_targets:
			target_units.append(target_data["target"])
		var high_aggro_targets = FilterTargetsByStat(target_units, func(u: Unit): return u.Data.Aggro, true)
		var final_target_unit = TargetByStat(high_aggro_targets, func(u: Unit): return u.CurrentHP)
		
		var final_target_data = null
		for target_data in reachable_targets:
			if target_data["target"] == final_target_unit:
				final_target_data = target_data
				break
		
		var destination = final_target_data["destination"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		print("%s chooses to attack %s" % [owner.name, final_target_unit.name])
		if destination != current_tile:
			await MoveCommand(owner, manager, destination)
		await AttackCommand(owner, manager, final_target_unit)

func execute_offensive_routine(owner: Unit, manager: GameManager):
	await AttackRoutine(owner, manager)
	if owner.HasActed == true:
		return
	await ActionMovementRoutine(owner, manager, manager.PlayerUnits)
	await AttackRoutine(owner, manager)

# This is the "brain" function. It takes the unit that owns the AI (owner)
# and a reference to the main manager script to access its helper functions.
# It needs to be async so it can wait for animations.
######################
#    AI TURN LOGIC   #
######################
func execute_turn(owner: Unit, _manager: GameManager):
	# Await is needed for the function to be async.
	await owner.get_tree().create_timer(0.01).timeout
	pass

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
