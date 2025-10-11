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

func ActionCommand(action: Action, owner: Unit, manager: GameManager, target = null):
	print("trying to act")
	print(action.Name)
	match action.Type:
		Action.ActionTypes.MOVE:
			if target is not Vector2i:
				push_error("MoveAction wrong target type")
				return
			await MoveCommand(action, owner, manager, target)
		Action.ActionTypes.ATTACK:
			if target is not Unit:
				push_error("AttackAction wrong target type")
				return
			await AttackCommand(action, owner, manager, target)
		Action.ActionTypes.RANDOMATTACK:
			if target != null:
				push_error("RanAttackAction wrong target type")
				return
			await RandomAttackCommand(action, owner, manager, target)
		Action.ActionTypes.AOEATTACK:
			if target is not Vector2i:
				push_error("AOEAttackAction wrong target type")
				return
			await AOEAttackCommand(action, owner, manager, target)
		Action.ActionTypes.HEAL:
			if target is not Unit:
				push_error("HealAction wrong target type")
				return
			await HealCommand(action, owner, manager, target)
		Action.ActionTypes.STATUS:
			if target is not Unit and target != null:
				push_error("StatusAction wrong target type")
				return
			await StatusCommand(action, owner, manager, target)
		Action.ActionTypes.SUMMON:
			if target != null:
				push_error("SummonAction wrong target type")
				return
			await SummonCommand(action, owner, manager, target)
		Action.ActionTypes.TERRAIN:
			if target is not Vector2i:
				push_error("TerrainAction wrong target type")
				return
			await TerrainCommand(action, owner, manager, target)

#Leaving as separate functions for now even if they are mostly the same,
#to see if its necessary to make changes later on
func MoveCommand(action: Action, owner: Unit, manager: GameManager, target: Vector2i):
	var move_tween = await action._execute(owner, manager, target)
	if move_tween is Tween:
		await move_tween.finished

func AttackCommand(action: Action, owner: Unit, manager: GameManager, target: Unit):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

func RandomAttackCommand(action: Action, owner: Unit, manager: GameManager, target = null):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

func AOEAttackCommand(action: Action, owner: Unit, manager: GameManager, target: Vector2i):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

func HealCommand(action: Action, owner: Unit, manager: GameManager, target: Unit):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

func StatusCommand(action: Action, owner: Unit, manager: GameManager, target: Unit):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

func SummonCommand(action: Action, owner: Unit, manager: GameManager, target = null):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

func TerrainCommand(action: Action, owner: Unit, manager: GameManager, target: Vector2i):
	await GeneralFunctions.Wait(0.3)
	await action._execute(owner, manager, target)
	await GeneralFunctions.Wait(0.4)

##############################################################
#                        2.2 TARGETTING                      #
##############################################################

func AttackTargeting(owner: Unit, manager: GameManager):
	var possible_targets : Array[Unit] = []
	var hostile_array : Array[Unit] = UnitManager.GetHostileArray(owner)
	
	possible_targets = AILogic.GetTargetsInRange(owner, manager, hostile_array)
	
	if possible_targets.is_empty():
		print("No target in attack range")
		return null
	else:
		var high_aggro_targets = AILogic.FilterTargetsByStat(possible_targets, func(u: Unit): return u.Aggro, true)
		var target = AILogic.TargetByStat(high_aggro_targets, func(u:Unit): return u.CurrentHP)
		return target

func HealTargeting(owner: Unit, manager: GameManager):
	var possible_targets : Array[Unit] = []
	var affiliation_array : Array[Unit] = UnitManager.GetAffiliationArray(owner)
	
	possible_targets = AILogic.GetTargetsInRange(owner, manager, affiliation_array)
	
	if possible_targets.is_empty():
		print("No target in heal range")
		return null
	else:
		var target = AILogic.TargetByStat(possible_targets, func(u : Unit): return u.HPPercent)
		return target

##############################################################
#                      2.3  AI ROUTINES                      #
##############################################################
######################
#   ROUTINE BLOCKS   #
######################

func AttackRoutine(action: Action, owner: Unit, manager: GameManager):
	var target = AttackTargeting(owner, manager)
	if target is Unit:
		print("%s chooses to attack %s" % [owner.Data.Name, target.Data.Name])
		await ActionCommand(action, owner, manager, target)

func HealRoutine(action: Action, owner: Unit, manager: GameManager):
	var target = HealTargeting(owner, manager)
	if target is Unit:
		print("%s chooses to heal %s" % [owner.Data.Name, target.Data.Name])
		await ActionCommand(action, owner, manager, target)

func MovementRoutine(action: Action, owner: Unit, manager: GameManager, path: Array[Vector2i]):
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
			await ActionCommand(action, owner, manager, final_destination)

func TileMovementRoutine(action: Action, owner: Unit, manager: GameManager, target_tiles: Array[Vector2i]):
	var valid_tiles = AILogic.GetValidTiles(owner, manager, target_tiles)
	if valid_tiles.is_empty():
		print("%s has no valid path to any target tile." % owner.Data.Name)
		return
	
	valid_tiles.sort_custom(func(a, b): 
		return a.cost < b.cost
		)
	
	var best_tile = valid_tiles[0]
	var path_to_destination = best_tile["path"]
	await MovementRoutine(action, owner, manager, path_to_destination)

func ActionMovementRoutine(action: Action, owner: Unit, manager: GameManager, targets: Array[Unit]):
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
	await MovementRoutine(action, owner, manager, path_to_destination)

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
	var targets_array : Array[Unit] = UnitManager.GetHostileArray(owner)
	
	var reachable_targets_data = AILogic.GetReachableTargets(owner, manager, targets_array)
	if reachable_targets_data.is_empty():
		print("%s cannot reach any target to attack this turn" % owner.Data.Name)
		return {}
	
	var reachable_targets: Array[Unit] = []
	for target_data in reachable_targets_data:
		reachable_targets.append(target_data["target"])
	var high_aggro_targets = AILogic.FilterTargetsByStat(reachable_targets, func(u: Unit): return u.Aggro, true)
	var final_target = AILogic.TargetByStat(high_aggro_targets, func(u: Unit): return u.CurrentHP)
	
	return FindBestDestination(final_target, reachable_targets_data)

func FindHealOpportunity(owner: Unit, manager: GameManager) -> Dictionary:
	var targets_array: Array[Unit] = UnitManager.GetAffiliationArray(owner)
	
	var damaged_targets: Array[Unit] = []
	
	for target in targets_array:
		if target != owner and target.CurrentHP < target.MaxHP:
			damaged_targets.append(target)
	if damaged_targets.is_empty():
		return {}
	
	var reachable_damaged_targets_data = AILogic.GetReachableTargets(owner, manager, damaged_targets)
	if reachable_damaged_targets_data.is_empty():
		print("%s cannot reach any target to heal this turn" % owner.Data.Name)
		return {}
	
	var reachable_damaged_targets: Array[Unit] = []
	for target_data in reachable_damaged_targets_data:
		reachable_damaged_targets.append(target_data["target"])
	var high_aggro_targets = AILogic.FilterTargetsByStat(reachable_damaged_targets, func(u: Unit): return u.SupportAggro, true)
	var final_target = AILogic.TargetByStat(high_aggro_targets, func(u: Unit): return u.HPPercent)
	
	return FindBestDestination(final_target, reachable_damaged_targets_data)

######################
#    ROUTINE LOGIC   #
######################

func ExecuteOffensiveRoutine(move_action: Action, attack_action: Action, owner: Unit, manager: GameManager):
	var attack_opportunity = FindAttackOpportunity(owner, manager)
	if not attack_opportunity.is_empty():
		var destination = attack_opportunity["destination"]
		var target = attack_opportunity["target"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		
		if destination != current_tile:
			if owner.HasMoved == true:
				return
			await ActionCommand(move_action, owner, manager, destination)
		await ActionCommand(attack_action, owner, manager, target)

func ExecuteMoveOffensiveRoutine(move_action: Action, attack_action: Action, owner: Unit, manager: GameManager):
	await ExecuteOffensiveRoutine(move_action, attack_action, owner, manager)
	if owner.HasActed == true:
		return
	
	var targets_array : Array[Unit] = UnitManager.GetHostileArray(owner)
	
	await ActionMovementRoutine(move_action, owner, manager, targets_array)

func ExecuteHealingRoutine(move_action: Action, heal_action: Action, owner: Unit, manager: GameManager):
	var heal_opportunity = FindHealOpportunity(owner, manager)
	if not heal_opportunity.is_empty():
		var destination = heal_opportunity["destination"]
		var target = heal_opportunity["target"]
		var current_tile = manager.GroundGrid.local_to_map(owner.global_position)
		
		if destination != current_tile:
			if owner.HasMoved == true:
				return
			await ActionCommand(move_action, owner, manager, destination)
		await ActionCommand(heal_action, owner, manager, target)

func ExecuteMoveHealingRoutine(move_action: Action, heal_action: Action, owner: Unit, manager: GameManager):
	await ExecuteHealingRoutine(move_action, heal_action, owner, manager)
	if owner.HasActed == true:
		return
	
	var targets_array : Array[Unit] = UnitManager.GetAffiliationArray(owner)
	
	var valid_targets_data = AILogic.GetValidTargets(owner, manager, targets_array)
	if not valid_targets_data.is_empty():
		var damaged_targets = []
		
		for target_data in valid_targets_data:
			var target = target_data["target"]
			if target != owner and target.CurrentHP < target.MaxHP:
				damaged_targets.append(target)
				break
		
		if not damaged_targets.is_empty():
			await ActionMovementRoutine(move_action, owner, manager, targets_array)
			return

######################
#  ADV ROUTINE LOGIC #
######################

func ExecuteOffensiveLogic(move_action: Action, attack_action: Action, owner: Unit, manager: GameManager, ai: AI):
	if ai.IsMobile == false:
		await ExecuteOffensiveRoutine(move_action, attack_action, owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
		return
	
	if not ai.TargetTiles.is_empty():
		if not ai.IgnorePlayers:
			await ExecuteOffensiveRoutine(move_action, attack_action, owner, manager)
			if owner.HasActed == true:
				return
		
		await TileMovementRoutine(move_action, owner, manager, ai.TargetTiles)
		return

	await ExecuteMoveOffensiveRoutine(move_action, attack_action, owner, manager)

func ExecuteSupportLogic(move_action: Action, attack_action: Action, heal_action: Action, owner: Unit, manager: GameManager, ai: AI):
	if ai.IsMobile == false:
		await ExecuteHealingRoutine(move_action, heal_action, owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
			return
		print(owner.Data.Name + " found no one to heal, and will attack instead.")
		await ExecuteOffensiveRoutine(move_action, attack_action, owner, manager)
		if owner.HasActed == true:
			ai.IsMobile = true
		return
	
	if not ai.TargetTiles.is_empty():
		if not ai.IgnorePlayers:
			await ExecuteHealingRoutine(move_action, heal_action, owner, manager)
			if owner.HasActed == true:
				return
			print(owner.Data.Name + " found no one to heal, and will attack instead.")
			await ExecuteOffensiveRoutine(move_action, attack_action, owner, manager)
			if owner.HasActed == true:
				return
		
		await TileMovementRoutine(move_action, owner, manager, ai.TargetTiles)
		return
	
	await ExecuteMoveHealingRoutine(move_action, heal_action, owner, manager)
	if owner.HasActed == true:
		return
	print(owner.Data.Name + " found no one to heal, and will attack instead.")
	
	if owner.HasMoved == true:
		await ExecuteOffensiveRoutine(move_action, attack_action, owner, manager)
		return
	await ExecuteMoveOffensiveRoutine(move_action, attack_action, owner, manager)

######################
#    AI TURN LOGIC   #
######################

func execute_turn(_owner: Unit, _manager: GameManager):
	await GeneralFunctions.Wait(0.01)
	pass

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
