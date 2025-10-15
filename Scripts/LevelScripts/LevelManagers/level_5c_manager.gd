extends BossLevelManager

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

@export var TargetTiles: Array[Vector2i]
var MarkedTiles: Array[Vector2i]

##############################################################
#                      2.0 Functions                         #
##############################################################

func CreateEruption():
	print("creating eruption")
	for tile in MarkedTiles:
		var tile_grid_position: Vector2 = MyGameManager.GroundGrid.map_to_local(tile)
		var tile_global_position: Vector2 = MyGameManager.GroundGrid.to_global(tile_grid_position)
		request_vfx.emit(LevelVFX, "eruption", tile_global_position)
	await GeneralFunctions.Wait(0.6)
	
	for tile in MarkedTiles:
		var unit = MyGameManager.GetUnitAtTile(tile)
		if unit != null:
			unit.TakeTileDamage(TileManager.TileTypes.FIRE, 20, true)

func TurnStarted(turn_number: int):
	if turn_number == 1:
		return
	
	print(turn_number)
	if turn_number % 2 == 0:
		TargetTiles.shuffle()
		var target_tiles: Array[Vector2i] = TargetTiles.slice(0,4)
		for tile in target_tiles:
			LevelHighlightLayer.set_cell(tile, 1, Vector2i(3, 0))
			MarkedTiles.append(tile)
	
	else:
		await CreateEruption()
		MarkedTiles.clear()
		LevelHighlightLayer.clear()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
