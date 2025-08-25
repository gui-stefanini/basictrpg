class_name ActionManager
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
var GameManagerRef: GameManager
var GroundGrid: TileMapLayer
var HighlightLayer: TileMapLayer
var MoveManagerRef: MoveManager
var ActionForecast: PanelContainer

######################
#     SCRIPT-WIDE    #
######################
var HighlightedMoveTiles: Array[Vector2i] = []
var HighlightedAttackTiles: Array[Vector2i] = []
var HighlightedHealTiles: Array[Vector2i] = []

##############################################################
#                      2.0 Functions                         #
##############################################################

func initialize(game_manager: GameManager):
	GameManagerRef = game_manager
	GroundGrid = GameManagerRef.GroundGrid
	HighlightLayer = GameManagerRef.HighlightLayer
	MoveManagerRef = GameManagerRef.MyMoveManager
	ActionForecast = GameManagerRef.ActionForecast

##############################################################
#                      2.1 RANGE CALC                        #
##############################################################

func AreTilesInRange(action_range: int, tile1: Vector2i, tile2: Vector2i) -> bool:
	var distance = abs(tile1.x - tile2.x) + abs(tile1.y - tile2.y)
	return distance > 0 and distance <= action_range 

func GetTilesInRange(start_tile: Vector2i, action_range: int) -> Array[Vector2i]:
	var tiles_in_range: Array[Vector2i] = []
	
	for x in range(-action_range, action_range + 1):
		for y in range(-action_range, action_range + 1):
			var distance = abs(x) + abs(y)
			if distance <= action_range:
				tiles_in_range.append(start_tile + Vector2i(x, y))
	
	tiles_in_range.erase(start_tile)
	return tiles_in_range

##############################################################
#                      2.2 HIGHLIGHTING                      #
##############################################################
func DrawHighlights(tiles_to_highlight:Array[Vector2i], highlight_source_id:int, highlight_atlas_coord:Vector2i):
	for tile in tiles_to_highlight:
		HighlightLayer.set_cell(tile, highlight_source_id, highlight_atlas_coord)

func ClearHighlights():
	HighlightLayer.clear()
	HighlightedMoveTiles.clear()
	HighlightedAttackTiles.clear()
	HighlightedHealTiles.clear()

func HighlightMoveArea(unit: Unit):
	ClearHighlights()
	var unit_grid_position = GroundGrid.local_to_map(unit.global_position)
	
	HighlightedMoveTiles = MoveManagerRef.GetReachableTiles(unit, unit_grid_position)
	
	DrawHighlights(HighlightedMoveTiles, 1, Vector2i(0,0))

func HighlightAttackArea(unit: Unit, action_range: int):
	ClearHighlights()
	var unit_tile = GroundGrid.local_to_map(unit.global_position)
	HighlightedAttackTiles = GetTilesInRange(unit_tile, action_range)
	DrawHighlights(HighlightedAttackTiles, 1, Vector2i(1,0))

func HighlightHealArea(unit: Unit, action_range: int):
	ClearHighlights()
	var unit_tile = GroundGrid.local_to_map(unit.global_position)
	HighlightedHealTiles = GetTilesInRange(unit_tile, action_range)
	DrawHighlights(HighlightedHealTiles, 1, Vector2i(2,0))

##############################################################
#                      2.3 EXECUTION                         #
##############################################################
func ExecuteAction(action: Action, unit: Unit, target = null):
	await action._execute(unit, GameManagerRef, target)
	GameManagerRef.CurrentAction = null
	GameManagerRef.TargetedUnit = null

func SimulateAction(action: Action, unit: Unit, target = null):
	await action._execute(unit, GameManagerRef, target, true)

func ForecastAction(action: Action, unit: Unit, target: Unit):
	var simulated_unit = unit.duplicate() as Unit
	GameManagerRef.add_child(simulated_unit)
	simulated_unit.CopyState(unit)
	var simulated_target = target.duplicate() as Unit
	GameManagerRef.add_child(simulated_target)
	simulated_target.CopyState(target)
	
	await SimulateAction(action, simulated_unit, simulated_target)
	
	var damage = target.CurrentHP - simulated_target.CurrentHP
	ActionForecast.UpdateForecast(unit, target, damage)
	
	simulated_unit.queue_free()
	simulated_target.queue_free()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
