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

@export var IsMobile : bool = true
@export var IgnorePlayers: bool = false

##############################################################
#                      2.0 Functions                         #
##############################################################
##############################################################
#                      2.1  COMMANDS                         #
##############################################################

func MoveCommand(owner: Unit, manager: GameManager, destination: Vector2i):
	for action in owner.Data.Actions:
		if action is MoveAction:
			var move_tween = action._execute(owner, manager, destination)
			if move_tween is Tween:
				await move_tween.finished
			break

func AttackCommand(owner: Unit, manager: GameManager, target: Unit):
		for action in owner.Data.Actions:
			if action is AttackAction:
				await GeneralFunctions.Wait(0.3)
				await action._execute(owner, manager, target)
				await GeneralFunctions.Wait(0.4)
				break

func DefendCommand(owner: Unit, manager: GameManager):
	print(owner.Data.Name + " is low on health and chooses to defend!")
	for action in owner.Data.Actions:
		if action is DefendAction:
			await action._execute(owner, manager)
			await GeneralFunctions.Wait(0.3)
			break

func HealCommand(owner: Unit, manager: GameManager, target: Unit):
	for action in owner.Data.Actions:
		if action is HealAction:
			print(owner.Data.Name + " heals " + target.Data.Name)
			await action._execute(owner, manager, target)
			await GeneralFunctions.Wait(0.3)
			break


##############################################################
#                        2.2 TARGETTING                      #
##############################################################

func AttackTargeting(owner: Unit, manager: GameManager):
	var possible_targets = AILogic.GetTargetsInRange(owner, manager, manager.PlayerUnits)
	
	if possible_targets.is_empty():
		print("No target in attack range")
		return null
	else:
		var high_aggro_targets = AILogic.FilterTargetsByStat(possible_targets, func(u: Unit): return u.Aggro, true)
		var target = AILogic.TargetByStat(high_aggro_targets, func(u:Unit): return u.CurrentHP)
		return target

func HealTargeting(owner: Unit, manager: GameManager):
	var possible_targets = AILogic.GetTargetsInRange(owner, manager, manager.EnemyUnits)
	
	if possible_targets.is_empty():
		print("No target in heal range")
		return null
	else:
		var target = AILogic.TargetByStat(possible_targets, func(u : Unit): return u.HPPercent)
		#var target = TargetByStat(possible_targets, "HPPercent")
		return target

##############################################################
#                      2.3  AI ROUTINES                      #
##############################################################
######################
#   ROUTINE BLOCKS   #
######################

func AttackRoutine(owner: Unit, manager: GameManager):
	var target = AttackTargeting(owner, manager)
	if target is Unit:
		print("%s chooses to attack %s" % [owner.Data.Name, target.Data.Name])
		await AttackCommand(owner, manager, target)

func HealRoutine(owner: Unit, manager: GameManager):
	var target = HealTargeting(owner, manager)
	if target is Unit:
		print("%s chooses to heal %s" % [owner.Data.Name, target.Data.Name])
		await HealCommand(owner, manager, target)

func MovementRoutine(owner: Unit, manager: GameManager, path: Array[Vector2i]):
	var path_within_move_range: Array[Vector2i] = []
	var enemy_tile = manager.GroundGrid.local_to_map(owner.global_position)
	var reachable_tiles = manager.MyMoveManager.GetReachableTiles(owner, enemy_tile)
	
	for tile in path:
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

func TileMovementRoutine(owner: Unit, manager: GameManager, target_tiles: Array[Vector2i]):
	var valid_tiles = AILogic.GetValidTiles(owner, manager, target_tiles)
	if valid_tiles.is_empty():
		print("%s has no valid path to any target tile." % owner.Data.Name)
		return
	
	valid_tiles.sort_custom(func(a, b): 
		return a.cost < b.cost
		)
	
	var best_tile = valid_tiles[0]
	var path_to_destination = best_tile["path"]
	await MovementRoutine(owner, manager, path_to_destination)

func ActionMovementRoutine(owner: Unit, manager: GameManager, targets: Array[Unit]):
	var valid_targets = AILogic.GetValidTargets(owner, manager, targets)
	if valid_targets.is_empty():
		print("%s has no valid path to any target." % owner.Data.Name)
		return
		
	valid_targets.sort_custom(func(a, b): 
		return a.cost < b.cost
		)
	
	var best_target = valid_targets[0]
	var target_player = best_target["target"]
	var path_to_destination = best_target["path"]
	print(target_player)
	await MovementRoutine(owner, manager, path_to_destination)

func FindBestDestination(final_target: Unit, targets_data: Array) -> Dictionary:
	var final_target_data = null
	
	for target_data in targets_data:
		if target_data["target"] == final_target:
			final_target_data = target_data
			break
	
	var destination = final_target_data["destination"]
	print("Found action opportunity for %s" % [final_target.Data.Name])
	
	return {
		"target": final_target,
		"destination": destination
	}

func FindAttackOpportunity(owner: Unit, manager: GameManager) -> Dictionary:
	var player_units : Array[Unit] = manager.PlayerUnits
	var reachable_player_units = AILogic.GetReachableTargets(owner, manager, player_units)
	if reachable_player_units.is_empty():
		print("%s cannot reach any target to attack this turn" % owner.Data.Name)
		return {}
	
	var target_units: Array[Unit] = []
	for target_data in reachable_player_units:
		target_units.append(target_data["target"])
	var high_aggro_targets = AILogic.FilterTargetsByStat(target_units, func(u: Unit): return u.Aggro, true)
	var final_target = AILogic.TargetByStat(high_aggro_targets, func(u: Unit): return u.CurrentHP)
	
	return FindBestDestination(final_target, reachable_player_units)

func FindHealOpportunity(owner: Unit, manager: GameManager) -> Dictionary:
	var damaged_allies: Array[Unit] = []
	for ally in manager.EnemyUnits:
		if ally != owner and ally.CurrentHP < ally.MaxHP:
			damaged_allies.append(ally)
	if damaged_allies.is_empty():
		return {}
	
	var reachable_damaged_allies = AILogic.GetReachableTargets(owner, manager, damaged_allies)
	if reachable_damaged_allies.is_empty():
		print("%s cannot reach any target to heal this turn" % owner.Data.Name)
		return {}
	
	var target_allies: Array[Unit] = []
	for target_data in reachable_damaged_allies:
		target_allies.append(target_data["target"])
	var high_aggro_targets = AILogic.FilterTargetsByStat(target_allies, func(u: Unit): return u.SupportAggro, true)
	var final_target = AILogic.TargetByStat(high_aggro_targets, func(u: Unit): return u.HPPercent)
	
	return FindBestDestination(final_target, reachable_damaged_allies)


######################
#    ROUTINE LOGIC   #
######################

func ExecuteOffensiveRoutine(owner: Unit, manager: GameManager):
	var attack_opportunity = FindAttackOpportunity(owner, manager)
	if not attack_opportunity.is_empty():
		var destination = attack_opportunity["destination"]
		var target = attack_opportunity["target"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		
		if destination != current_tile:
			if owner.HasMoved == true:
				return
			await MoveCommand(owner, manager, destination)
		await AttackCommand(owner, manager, target)

func ExecuteMoveOffensiveRoutine(owner: Unit, manager: GameManager):
	await ExecuteOffensiveRoutine(owner, manager)
	if owner.HasActed == true:
		return
	
	await ActionMovementRoutine(owner, manager, manager.PlayerUnits)

func ExecuteHealingRoutine(owner: Unit, manager: GameManager):
	var heal_opportunity = FindHealOpportunity(owner, manager)
	if not heal_opportunity.is_empty():
		var destination = heal_opportunity["destination"]
		var target = heal_opportunity["target"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		
		if destination != current_tile:
			if owner.HasMoved == true:
				return
			await MoveCommand(owner, manager, destination)
		await HealCommand(owner, manager, target)

func ExecuteMoveHealingRoutine(owner: Unit, manager: GameManager):
	await ExecuteHealingRoutine(owner, manager)
	if owner.HasActed == true:
		return
	
	var allies = AILogic.GetValidTargets(owner, manager, manager.EnemyUnits)
	if not allies.is_empty():
		var damaged_allies = []
		
		for ally in allies:
			var unit = ally["target"]
			if unit != owner and unit.CurrentHP < unit.MaxHP:
				damaged_allies.append(ally)
		
		if not damaged_allies.is_empty():
			await ActionMovementRoutine(owner, manager, manager.EnemyUnits)
			return

######################
#  ADV ROUTINE LOGIC #
######################

func ExecuteOffensiveLogic(owner: Unit, manager: GameManager, ai: AI):
	if ai.IsMobile == false:
		await ExecuteOffensiveRoutine(owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
		return
	
	if not ai.TargetTiles.is_empty():
		if not ai.IgnorePlayers:
			await ExecuteOffensiveRoutine(owner, manager)
			if owner.HasActed == true:
				return
		
		await TileMovementRoutine(owner, manager, ai.TargetTiles)
		return

	await ExecuteMoveOffensiveRoutine(owner, manager)

func ExecuteSupportLogic(owner: Unit, manager: GameManager, ai: AI):
	if ai.IsMobile == false:
		await ExecuteHealingRoutine(owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
			return
		print(owner.Data.Name + " found no one to heal, and will attack instead.")
		await ExecuteOffensiveRoutine(owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
		return
	
	if not ai.TargetTiles.is_empty():
		if not ai.IgnorePlayers:
			await ExecuteHealingRoutine(owner, manager)
			if owner.HasActed == true:
				return
			print(owner.Data.Name + " found no one to heal, and will attack instead.")
			await ExecuteOffensiveRoutine(owner, manager)
			if owner.HasActed == true:
				return
		
		await TileMovementRoutine(owner, manager, ai.TargetTiles)
		return
	
	await ExecuteMoveHealingRoutine(owner, manager)
	if owner.HasActed == true:
		return
	print(owner.Data.Name + " found no one to heal, and will attack instead.")
	
	if owner.HasMoved == true:
		await ExecuteOffensiveRoutine(owner, manager)
		return
	await ExecuteMoveOffensiveRoutine(owner, manager)

######################
#    AI TURN LOGIC   #
######################
func execute_turn(_owner: Unit, _manager: GameManager):
	# Await is needed for the function to be async.
	await GeneralFunctions.Wait(0.01)
	pass

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
