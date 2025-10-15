class_name GridCursor
extends Node2D

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var MySprite: Sprite2D

######################
#     SCRIPT-WIDE    #
######################

var TilePosition: Vector2i
var Enabled: bool = true

##############################################################
#                      2.0 Functions                         #
##############################################################

func MoveToTile(manager: GameManager, new_tile: Vector2i):
	TilePosition = new_tile
	# map_to_local gives the center position of the cell
	var cell_center_local_pos = manager.GroundGrid.map_to_local(TilePosition)
	# We need to convert this local position to a global one
	global_position = manager.GroundGrid.to_global(cell_center_local_pos)
	
	var tile_type: String = manager.GetTileType(new_tile)
	UpdateSprite(tile_type)
	

func UpdateSprite(tile_type: String):
	match tile_type:
		"Floor", "Wall":
			MySprite.frame_coords = Vector2i(0,1)
			return
	
	MySprite.frame_coords = Vector2i(0,0)

func Disable():
	Enabled = false
	hide()

func Enable():
	Enabled = true
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
