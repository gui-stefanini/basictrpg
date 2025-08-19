class_name AIBehavior
extends Resource

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

func GetTargetsInRange(owner: Unit, manager: GameManager, targets: Array[Unit]):
	var unit_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var possible_targets : Array[Unit] = []
	for target in targets:
		var target_tile = manager.GroundGrid.local_to_map(target.global_position)
		if manager.AreTilesInRange(owner.Data.AttackRange, unit_tile, target_tile):
			possible_targets.append(target)
	return possible_targets

func HealTargeting(owner: Unit, manager: GameManager):
	var possible_targets = GetTargetsInRange(owner, manager, manager.EnemyUnits)
	
	if possible_targets.is_empty():
		print("No target in heal range")
		return null
	else:
		possible_targets.sort_custom(
		func(a, b):
			var health_percent_a = float(a.CurrentHP) / a.Data.MaxHP
			var health_percent_b = float(b.CurrentHP) / b.Data.MaxHP
			return health_percent_a < health_percent_b
		)
		var target = possible_targets[0]
		return target

func AttackTargeting(owner: Unit, manager: GameManager):
	var possible_targets = GetTargetsInRange(owner, manager, manager.PlayerUnits)
	
	if possible_targets.is_empty():
		print("No target in attack range")
		return null
	else:
		var target : Unit = possible_targets.pick_random()
		return target

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

func GetValidActionTiles(attacker: Unit, manager: GameManager, target: Unit) -> Array[Vector2i]:
	var move_data_name = attacker.Data.MovementType.Name
	var astar : AStar2D = manager.MyMoveManager.AStarInstances[move_data_name]
	var valid_tiles: Array[Vector2i] = []
	var target_tile = manager.GroundGrid.local_to_map(target.global_position)
	var tiles_in_range = manager.GetTilesInRange(target_tile, attacker.Data.AttackRange)
	var occupied_tiles = manager.MyMoveManager.GetOccupiedTiles()

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

#func FindHealOpportunity(healer: Unit, manager: GameManager) -> Dictionary:
	#var allies = GetValidTargets(healer, manager, manager.EnemyUnits)
	#
	#var damaged_allies = []
	#for ally in allies:
		#var unit = ally["target"]
		#if unit != healer and unit.CurrentHP < unit.Data.MaxHP:
			#damaged_allies.append(ally)
	#
	#if damaged_allies.is_empty():
		#return {}
	#
	#damaged_allies.sort_custom(
	#func(a, b):
		#var health_percent_a = float(a["target"].CurrentHP) / a["target"].Data.MaxHP
		#var health_percent_b = float(b["target"].CurrentHP) / b["target"].Data.MaxHP
		#return health_percent_a < health_percent_b
	#)
	#var lowest_health_ally = damaged_allies[0]["target"]
	#var lowest_health_percent = float(lowest_health_ally.CurrentHP) / lowest_health_ally.Data.MaxHP
	#
	#for ally in damaged_allies:
		#var unit = ally["target"]
		#var ally_health_percent = float(unit.CurrentHP) / unit.Data.MaxHP
		#if ally_health_percent > lowest_health_percent:
			#damaged_allies.erase(ally)
	#
	#var healer_tile = manager.GroundGrid.local_to_map(healer.global_position)
	#var reachable_tiles = manager.GetReachableTiles(healer, healer_tile)
	#reachable_tiles.append(healer_tile) # Can heal from current position
	#
	#var reachable_allies = []
	#for ally in damaged_allies:
		#var potential_heal_tiles = GetValidActionTiles(healer, manager, ally["target"])
		#
		#for heal_tile in potential_heal_tiles:
			#if reachable_tiles.has(heal_tile):
				## Found a valid tile to move to and heal from
				#print("Found heal opportunity for " + healer.name + " -> " + ally["target"].name)
				#reachable_allies.append(ally)
				#return {"target": ally, "destination": heal_tile}
	#
	#reachable_allies.sort_custom(
	#func(a, b):
		#return a["cost"] < b["cost"]
	#)
	#var final_target = reachable_allies[0]
	#
	#for tile in final_target["path"]:
		#if reachable_tiles.has(tile):
			#return {"target": final_target["target"], "destination": tile}
	#return {}

func FindHealOpportunity(healer: Unit, manager: GameManager) -> Dictionary:
	var damaged_allies = []
	for ally in manager.EnemyUnits: # Make sure this targets the correct faction!
		if ally != healer and ally.CurrentHP < ally.Data.MaxHP:
			damaged_allies.append(ally)
	
	if damaged_allies.is_empty():
		return {}
	
	# Sort allies by the amount of damage taken (most damaged first)
	damaged_allies.sort_custom(
		func(a, b):
			var health_percentage_a = float(a.CurrentHP) / a.Data.MaxHP
			var health_percentage_b = float(b.CurrentHP) / b.Data.MaxHP
			return health_percentage_a > health_percentage_b
	)
	
	var healer_tile = manager.GroundGrid.local_to_map(healer.global_position)
	var reachable_tiles = manager.MyMoveManager.GetReachableTiles(healer, healer_tile)
	reachable_tiles.append(healer_tile) # The healer might not need to move
	
	for target_ally in damaged_allies:
		var potential_heal_tiles = GetValidActionTiles(healer, manager, target_ally)
		var best_tile_for_target = null
		var lowest_cost = INF
		
		# Find the cheapest tile to move to for healing this specific ally
		for heal_tile in potential_heal_tiles:
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

func ActionMovementRoutine(owner: Unit, manager: GameManager, targets: Array[Unit]):
	var valid_targets = GetValidTargets(owner, manager, targets)
	
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

func execute_offensive_routine(owner: Unit, manager: GameManager):
	await AttackRoutine(owner, manager)
	if owner.HasActed == true:
		return
	await ActionMovementRoutine(owner, manager, manager.PlayerUnits)
	await AttackRoutine(owner, manager)

# This is the "brain" function. It takes the unit that owns the AI (owner)
# and a reference to the main manager script to access its helper functions.
# It needs to be async so it can wait for animations.
func execute_turn(owner: Unit, _manager: GameManager):
	# Await is needed for the function to be async.
	await owner.get_tree().create_timer(0.01).timeout
	pass
