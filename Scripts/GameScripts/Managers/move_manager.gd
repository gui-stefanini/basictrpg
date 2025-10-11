class_name MoveManager
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

var MyGameManager : GameManager
var GroundGrid: TileMapLayer
var EffectLayer: TileMapLayer
@export var BaseMovementData: MovementData
@export var AllMovementData: Array[MovementData]

######################
#     SCRIPT-WIDE    #
######################

var AStarInstances: Dictionary = {}

##############################################################
#                      2.0 Functions                         #
##############################################################

func Initialize(game_manager: GameManager):
	MyGameManager = game_manager
	
	GroundGrid = MyGameManager.GroundGrid
	EffectLayer = MyGameManager.EffectLayer
	SetAStarGrids()

##############################################################
#                   2.1 VALID/INVALID LOGIC                  #
##############################################################

func SetUnitObstacles(active_unit: Unit, astar : AStar2D) -> Array[Vector2i]:
	if active_unit.ActiveStatuses.has(Unit.Status.PASS):
		return []
	
	var modified_tiles: Array[Vector2i] = []
	
	var hostile_array : Array[Unit] = UnitManager.GetHostileArray(active_unit)
	for unit in hostile_array:
		var unit_tile = GroundGrid.local_to_map(unit.global_position)
		astar.set_point_disabled(vector_to_id(unit_tile), true)
		modified_tiles.append(unit_tile)
	
	return modified_tiles

func ClearUnitObstacles(tiles_to_clear: Array[Vector2i], astar : AStar2D):
	for tile in tiles_to_clear:
		astar.set_point_disabled(vector_to_id(tile), false)

func GetOccupiedTiles(exception: Unit = null) -> Array[Vector2i]:
	var occupied_tiles: Array[Vector2i] = []
	
	for unit in UnitManager.AllUnits:
		occupied_tiles.append(GroundGrid.local_to_map(unit.global_position))
	if exception != null:
		occupied_tiles.erase(GroundGrid.local_to_map(exception.global_position))
	
	return occupied_tiles

func GetInvalidTiles(unit_data: CharacterData = null, move_data: MovementData = null, 
					 exclude_occupied: bool = false) -> Array[Vector2i]:
	if move_data == null:
		if unit_data.MovementType != null:
			move_data = unit_data.MovementType
		elif unit_data.CharacterMovementType != null:
			move_data = unit_data.CharacterMovementType
		else:
			move_data = unit_data.Class.ClassMovementType
	
	var astar : MovementAStar = AStarInstances[move_data.Name]
	var all_tiles: Array[Vector2i] = GroundGrid.get_used_cells()
	
	var occupied_tiles : Array[Vector2i] = []
	if exclude_occupied == false:
		occupied_tiles = GetOccupiedTiles()
	var invalid_tiles: Array[Vector2i] = []
	
	for tile in all_tiles:
		var point_id = vector_to_id(tile)
		if astar.is_point_disabled(point_id) or occupied_tiles.has(tile):
			invalid_tiles.append(tile)
	
	return invalid_tiles

func CheckGridBounds(tile: Vector2i) -> bool:
	var grid_rect = GroundGrid.get_used_rect()
	return grid_rect.has_point(tile)

##############################################################
#                      2.2 ASTAR PATHING                     #
##############################################################

func vector_to_id(vector: Vector2i) -> int:
	# Converts a Vector2i coordinate to a unique integer ID.
	# This is necessary because AStar2D identifies points with integer IDs, not vectors.
	# We use a large number to ensure the y-coordinate doesn't overlap with the x-coordinate.
	return vector.x * 1000 + vector.y

func SetAStarGrids():
	for move_data in AllMovementData:
		var new_astar = MovementAStar.new()
		new_astar.GroundGrid = GroundGrid
		new_astar.EffectLayer = EffectLayer
		new_astar.MovementType = move_data
		var all_cells = GroundGrid.get_used_cells()
		
		for cell in all_cells:
			var tile_data = GroundGrid.get_cell_tile_data(cell)
			if tile_data:
				var terrain_type: String = tile_data.get_custom_data("terrain_type")
				var move_cost = move_data.TerrainCosts.get(terrain_type, -1) # Default to -1 if type not found
				
				var point_id = vector_to_id(cell)
				new_astar.add_point(point_id, cell)
				
				if move_cost == -1:
					new_astar.set_point_disabled(point_id, true)
		
		for cell in all_cells:
			var current_point_id = vector_to_id(cell)
			if not new_astar.has_point(current_point_id) or new_astar.is_point_disabled(current_point_id):
				continue
			
			var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
			for direction in directions:
				var neighbor_cell = cell + direction
				var neighbor_point_id = vector_to_id(neighbor_cell)
				
				if new_astar.has_point(neighbor_point_id) and not new_astar.is_point_disabled(neighbor_point_id):
					new_astar.connect_points(current_point_id, neighbor_point_id)
					
		AStarInstances[move_data.Name] = new_astar

func FindPath(unit: Unit, start_tile: Vector2i, end_tile: Vector2i) -> Dictionary:
	var move_data_name = unit.Data.MovementType.Name
	if not AStarInstances.has(move_data_name):
		push_error("No AStar grid found for movement type: " + move_data_name)
		return {}
	var astar : AStar2D = AStarInstances[move_data_name]
	
	var modified_tiles = SetUnitObstacles(unit, astar)
	var start_id = vector_to_id(start_tile)
	var end_id = vector_to_id(end_tile)
	
	var astar_path_vectors = astar.get_point_path(start_id, end_id)
	
	var path: Array[Vector2i] = []
	for tile in astar_path_vectors:
		path.append(Vector2i(tile))
	
	if path.is_empty():
		ClearUnitObstacles(modified_tiles, astar)
		return {"path": [], "cost": INF}
	
	var path_cost = 0
	for i in range(1, path.size()):
		var tile_coord = path[i]
		var tile_data = GroundGrid.get_cell_tile_data(tile_coord)
		var effect_tile_data = EffectLayer.get_cell_tile_data(tile_coord)
		var terrain_type: String
		if not tile_data:
			push_error("No tile data")
			return {}
		
		if effect_tile_data:
			terrain_type = effect_tile_data.get_custom_data("terrain_type")
		else:
			terrain_type = tile_data.get_custom_data("terrain_type")
		path_cost += unit.Data.MovementType.TerrainCosts.get(terrain_type, 1)
		
	ClearUnitObstacles(modified_tiles, astar)
	
	return {"path" : path, "cost" : path_cost}

##############################################################
#                      2.3 MOVEMENT LOGIC                    #
##############################################################

func GetReachableTiles(unit: Unit, start_tile: Vector2i, include_self: bool = false) -> Array[Vector2i]:
	var move_range = unit.MoveRange
	var move_data_name = unit.Data.MovementType.Name
	var astar = AStarInstances[move_data_name]
	
	var modified_tiles = SetUnitObstacles(unit, astar)
	var tiles_to_check: Array[Vector2i] = [start_tile]
	var checked_tiles_costs: Dictionary = {start_tile: 0}
	
	var checked_tiles = 0
	while checked_tiles < tiles_to_check.size():
		var current_tile = tiles_to_check[checked_tiles]
		checked_tiles += 1
		
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		for direction in directions:
			var adjacent_tile = current_tile + direction
			
			if not astar.has_point(vector_to_id(adjacent_tile)) or astar.is_point_disabled(vector_to_id(adjacent_tile)):
				continue
			
			var tile_data = GroundGrid.get_cell_tile_data(adjacent_tile)
			var effect_tile_data = EffectLayer.get_cell_tile_data(adjacent_tile)
			
			if not tile_data:
				continue
			
			var terrain_type: String 
			if effect_tile_data:
				terrain_type = effect_tile_data.get_custom_data("terrain_type")
			else:
				terrain_type = tile_data.get_custom_data("terrain_type")
			var terrain_cost = unit.Data.MovementType.TerrainCosts.get(terrain_type, -1)
			if terrain_cost == -1:
				continue
			
			var new_cost = checked_tiles_costs[current_tile] + terrain_cost
			
			if new_cost <= move_range:
				if not checked_tiles_costs.has(adjacent_tile) or new_cost < checked_tiles_costs[adjacent_tile]:
					checked_tiles_costs[adjacent_tile] = new_cost
					tiles_to_check.push_back(adjacent_tile)
					
	var all_reachable_tiles = checked_tiles_costs.keys()
	var reachable_tiles: Array[Vector2i] = []
	
	var occupied_tiles = GetOccupiedTiles()
	for tile in all_reachable_tiles:
		if not occupied_tiles.has(tile) or tile == start_tile:
			reachable_tiles.append(tile)
	
	if include_self == false:
		reachable_tiles.erase(start_tile)
	ClearUnitObstacles(modified_tiles, astar)
	return reachable_tiles

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
