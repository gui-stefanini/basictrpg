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

######################
#     SCRIPT-WIDE    #
######################

var TilePosition: Vector2i

##############################################################
#                      2.0 Functions                         #
##############################################################

func MoveToTile(new_tile_position: Vector2i, grid: TileMapLayer):
	TilePosition = new_tile_position
	# map_to_local gives the center position of the cell
	var cell_center_local_pos = grid.map_to_local(TilePosition)
	# We need to convert this local position to a global one
	global_position = grid.to_global(cell_center_local_pos)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
