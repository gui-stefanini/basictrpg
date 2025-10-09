class_name TerrainAction
extends Action
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var ValidTerrainData: MovementData
@export var IgnoreUnits: bool
@export var AnimationName: String
@export var AtlasCoordinates: Vector2i
@export var ActionRange: int
@export var AOERange: int
@export var Duration: int

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func ModifyTerrain(tiles_to_modify: Array[Vector2i], manager : GameManager):
	for tile in tiles_to_modify:
		manager.EffectLayer.set_cell(tile, 2, AtlasCoordinates)
		manager.ChangedTiles[tile] = Duration

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.SubState.TARGETING_PHASE
	manager.MyActionManager.HighlightAOEArea(user, ActionRange, true)
	manager.MyActionManager.AOERange = AOERange
	manager.MyCursor.show()

func _check_target(_user: Unit, manager: GameManager = null, target = null) -> bool:
	if target is not Vector2i:
		return false
	
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	var invalid_tiles: Array[Vector2i] = manager.MyMoveManager.GetInvalidTiles(null, ValidTerrainData, IgnoreUnits)
	
	for tile in area:
		if invalid_tiles.has(tile):
			area.erase(tile)
	
	if area.is_empty():
		return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	print(user.Data.Name + " affects terrain!")
	
	var target_global_pos = manager.GroundGrid.to_global(manager.GroundGrid.map_to_local(target))
	await user.PlayActionAnimation(AnimationName, target_global_pos)
	
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	var invalid_tiles: Array[Vector2i] = manager.MyMoveManager.GetInvalidTiles(null, ValidTerrainData, IgnoreUnits)
	for tile in area:
		if invalid_tiles.has(tile):
			area.erase(tile)
	
	ModifyTerrain(area, manager)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
