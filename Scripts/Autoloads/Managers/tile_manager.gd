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

enum TileTypes {GRASS, FLOOR, WATER, FIRE, WALL}

@export var GrassTiles : Array[GroundTileData]
@export var FloorTiles : Array[GroundTileData]
@export var WaterTiles : Array[GroundTileData]
@export var FireTiles : Array[GroundTileData]
@export var WallTiles : Array[GroundTileData]

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func GetTileData(tile_type : TileTypes) -> Dictionary:
	var tile_data_array : Array[GroundTileData] = []
	match tile_type:
		TileTypes.GRASS:
			tile_data_array = GrassTiles
		TileTypes.WATER:
			tile_data_array = WaterTiles
		TileTypes.WALL:
			tile_data_array = WallTiles
		TileTypes.FIRE:
			tile_data_array = FireTiles
	
	var tile_data : GroundTileData = tile_data_array.pick_random()
	var tile_info : Dictionary = {"id" : tile_data.ID, "coordinates" : tile_data.Coordinates}
	
	return tile_info

func TurnStartEffect(unit: Unit, terrain_type: String):
	match terrain_type:
		"Fire":
			unit.TakeTileDamage(TileTypes.FIRE, 20, true)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
