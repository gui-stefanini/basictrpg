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
@export var TileType: TileManager.TileTypes
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
		var tile_info : Dictionary = TileManager.GetTileData(TileType)
		manager.EffectLayer.set_cell(tile, tile_info["id"], tile_info["coordinates"])
		manager.ChangedTiles[tile] = Duration

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.AOE, ActionRange, true)
	manager.MyActionManager.AOERange = AOERange
	manager.MyCursor.show()

func _check_target(_user: Unit, manager: GameManager = null, target = null) -> bool:
	if target is not Vector2i:
		return false
	
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	var invalid_tiles: Array[Vector2i] = manager.MyMoveManager.GetInvalidTiles(null, ValidTerrainData, IgnoreUnits)
	
	var final_area: Array[Vector2i]
	for tile in area:
		if not invalid_tiles.has(tile):
			final_area.append(tile)
	
	if final_area.is_empty():
		return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	print(user.Data.Name + " affects terrain!")
	
	var target_global_pos = manager.GroundGrid.to_global(manager.GroundGrid.map_to_local(target))
	await user.PlayActionAnimation(AnimationName, target_global_pos)
	
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	var invalid_tiles: Array[Vector2i] = manager.MyMoveManager.GetInvalidTiles(null, ValidTerrainData, IgnoreUnits)
	
	var final_area: Array[Vector2i]
	for tile in area:
		if not invalid_tiles.has(tile):
			final_area.append(tile)
	
	ModifyTerrain(final_area, manager)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
