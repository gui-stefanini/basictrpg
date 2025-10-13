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
var MyGameManager: GameManager
var MyMoveManager: MoveManager
var GroundGrid: TileMapLayer
var EffectLayer: TileMapLayer
var HighlightLayer: TileMapLayer
var CursorHighlightLayer : TileMapLayer
var ActionForecast: PanelContainer

######################
#     SCRIPT-WIDE    #
######################
enum HighlightTypes {MOVE, ATTACK, AOE,  SUPPORT}
var HighlightedMoveTiles: Array[Vector2i] = []
var HighlightedAttackTiles: Array[Vector2i] = []
var HighlightedAOETiles: Array[Vector2i] = []
var HighlightedHealTiles: Array[Vector2i] = []

var AOERange: int = -1 #For now, only works with diamond shape
var HighlightedCursorTiles: Array[Vector2i] = []

##############################################################
#                      2.0 Functions                         #
##############################################################

func Initialize(game_manager: GameManager):
	MyGameManager = game_manager
	GroundGrid = MyGameManager.GroundGrid
	EffectLayer = MyGameManager.EffectLayer
	HighlightLayer = MyGameManager.HighlightLayer
	CursorHighlightLayer = MyGameManager.CursorHighlightLayer
	MyMoveManager = MyGameManager.MyMoveManager
	ActionForecast = MyGameManager.ActionForecast

##############################################################
#                      2.1 RANGE CALC                        #
##############################################################

func AreTilesInRange(action_range: int, tile1: Vector2i, tile2: Vector2i) -> bool:
	var distance = abs(tile1.x - tile2.x) + abs(tile1.y - tile2.y)
	return distance > 0 and distance <= action_range 

func GetTilesInRange(start_tile: Vector2i, action_range: int, include_start: bool = false) -> Array[Vector2i]:
	var tiles_in_range: Array[Vector2i] = []
	
	for x in range(-action_range, action_range + 1):
		for y in range(-action_range, action_range + 1):
			var distance = abs(x) + abs(y)
			if distance <= action_range:
				tiles_in_range.append(start_tile + Vector2i(x, y))
	
	if include_start == false:
		tiles_in_range.erase(start_tile)
	
	for tile in tiles_in_range:
		if MyMoveManager.CheckGridBounds(tile) == false:
			tiles_in_range.erase(tile)
	
	return tiles_in_range

func GetTargetsInArea(area: Array[Vector2i], valid_targets: Array[Unit]) -> Array[Unit]:
	var final_targets: Array[Unit]
	for target in valid_targets:
		if target.CurrentTile in area:
			final_targets.append(target)
	
	return final_targets

##############################################################
#                      2.2 HIGHLIGHTING                      #
##############################################################
func ClearHighlights():
	HighlightLayer.clear()
	HighlightedMoveTiles.clear()
	HighlightedAttackTiles.clear()
	HighlightedHealTiles.clear()
	HighlightedAOETiles.clear()
	
	AOERange = -1
	ClearCursorHighlights()

func ClearCursorHighlights():
	CursorHighlightLayer.clear()
	HighlightedCursorTiles.clear()

func DrawHighlights(tiles_to_highlight:Array[Vector2i], highlight_source_id:int, highlight_atlas_coord:Vector2i, 
	 layer : TileMapLayer = HighlightLayer):
	for tile in tiles_to_highlight:
		layer.set_cell(tile, highlight_source_id, highlight_atlas_coord)

func HighlightArea(unit: Unit, type: HighlightTypes, action_range: int, include_start: bool = false):
	ClearHighlights()
	var unit_tile = unit.CurrentTile
	var highlight_array: Array[Vector2i]
	var atlas_coordinates: Vector2i
	
	match type:
		HighlightTypes.MOVE:
			HighlightedMoveTiles = MyMoveManager.GetReachableTiles(unit, unit_tile, include_start)
			DrawHighlights(HighlightedMoveTiles, 1, Vector2i(0,0))
			return
			
		HighlightTypes.ATTACK:
			highlight_array = HighlightedAttackTiles
			atlas_coordinates = Vector2i(1,0)
		HighlightTypes.AOE:
			highlight_array = HighlightedAOETiles
			atlas_coordinates = Vector2i(1,0)
		HighlightTypes.SUPPORT:
			highlight_array = HighlightedHealTiles
			atlas_coordinates = Vector2i(2,0)
	
	var new_array_value = GetTilesInRange(unit_tile, action_range, include_start)
	highlight_array.assign(new_array_value)
	DrawHighlights(highlight_array, 1, atlas_coordinates)

func UpdateAOE(cursor_tile : Vector2i):
	ClearCursorHighlights()
	HighlightedCursorTiles = GetTilesInRange(cursor_tile, AOERange, true)
	DrawHighlights(HighlightedCursorTiles, 1, Vector2i(0,0), CursorHighlightLayer)

##############################################################
#                2.3 INFORMATION GATHERING                   #
##############################################################

func GetUnitTileType(unit: Unit) -> String:
	var tile: Vector2i = unit.CurrentTile
	var tile_data = GroundGrid.get_cell_tile_data(tile)
	var effect_tile_data = EffectLayer.get_cell_tile_data(tile)
	var terrain_type: String
	if effect_tile_data:
		terrain_type = effect_tile_data.get_custom_data("terrain_type")
	else:
		terrain_type = tile_data.get_custom_data("terrain_type")
	return terrain_type

##############################################################
#                      2.4 EXECUTION                         #
##############################################################

func SelectAction(action: Action, user: Unit):
	MyGameManager.CurrentAction = action
	MyGameManager.CurrentSubState = GameManager.SubState.TARGETING_PHASE
	action._on_select(user, MyGameManager)

func CheckValidTarget(action: Action, unit: Unit, target = null) -> bool:
	return action._check_target(unit, MyGameManager, target)

func ExecuteAction(action: Action, unit: Unit, target = null):
	MyGameManager.CurrentSubState = GameManager.SubState.PROCESSING_PHASE
	
	var action_return = await action._execute(unit, MyGameManager, target)
	if action_return is Tween:
		await action_return.finished
	
	MyGameManager.CurrentAction = null
	MyGameManager.TargetedUnit = null
	if action.EndTurn == true:
		MyGameManager.OnPlayerUnitTurnFinished()
	else:
		MyGameManager.OnPlayerUnitActionFinished()

func SimulateAction(action: Action, unit: Unit, target = null):
	await action._execute(unit, MyGameManager, target, true)

func PreviewAction(action: Action, unit: Unit, target: Unit, forecast: bool = false) -> int:
	var simulated_unit = unit.duplicate() as Unit
	MyGameManager.add_child(simulated_unit)
	simulated_unit.CopyState(unit)
	var simulated_target = target.duplicate() as Unit
	MyGameManager.add_child(simulated_target)
	simulated_target.CopyState(target)
	
	await SimulateAction(action, simulated_unit, simulated_target)
	
	var damage = target.CurrentHP - simulated_target.CurrentHP
	
	if forecast == true:
		ActionForecast.UpdateForecast(unit, target, damage)
	
	simulated_unit.queue_free()
	simulated_target.queue_free()
	
	return damage

func StartCombat(attacker: Unit, defender: Unit, damage: int):
	var attacker_tile: String = GetUnitTileType(attacker)
	var defender_tile: String = GetUnitTileType(defender)
	
	var combat_scene : CombatScreen = MyGameManager.CombatScreenScene.instantiate()
	MyGameManager.add_child(combat_scene)
	
	var background_type: Level.BackgroundTypes = MyGameManager.CurrentLevel.BackgroundType
	
	combat_scene.ShowCombat(background_type, attacker, attacker_tile, defender, defender_tile, damage)
	await combat_scene.combat_finished

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
