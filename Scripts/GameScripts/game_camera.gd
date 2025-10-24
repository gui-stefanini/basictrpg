class_name GameCamera
extends Camera2D
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################

######################
#     REFERENCES     #
######################

var GroundGrid: TileMapLayer

######################
#     SCRIPT-WIDE    #
######################

var CameraSize: Vector2

var TopLimit: float
var LeftLimit: float
var BottomLimit: float
var RightLimit: float

var TopEdge : int
var LeftEdge : int
var BottomEdge : int
var RightEdge : int

##############################################################
#                      2.0 Functions                         #
##############################################################

func Initialize(tile_map: TileMapLayer):
	GroundGrid = tile_map
	CameraSize = get_viewport_rect().size
	SetLimits()

func SetLimits():
	var map_rect : Rect2i = GroundGrid.get_used_rect()
	var tile_size : Vector2i = GroundGrid.tile_set.tile_size
	
	TopLimit = map_rect.position.y * tile_size.y
	LeftLimit = map_rect.position.x * tile_size.x
	BottomLimit = max(TopLimit, (map_rect.end.y * tile_size.y) - CameraSize.y)
	RightLimit = max(LeftLimit, (map_rect.end.x * tile_size.x) - CameraSize.x)
	UpdateCameraEdges()

func MoveCamera(tile: Vector2i):
	var outside_edge : bool = CheckCameraEdge(tile)
	if outside_edge == false:
		return
	
	var tile_size : Vector2i = GroundGrid.tile_set.tile_size
	var tile_movement: Vector2i = Vector2i(0,0)
	if tile.y < TopEdge:
		tile_movement.y = tile.y - TopEdge
	if tile.x < LeftEdge:
		tile_movement.x = tile.x - LeftEdge
	if tile.y > BottomEdge:
		tile_movement.y = tile.y - BottomEdge
	if tile.x > RightEdge:
		tile_movement.x = tile.x - RightEdge
	
	var pixel_movement : Vector2 = Vector2(tile_movement * tile_size)
	var new_position = self.global_position + pixel_movement
	new_position.x = clamp(new_position.x, LeftLimit, RightLimit)
	new_position.y = clamp(new_position.y, TopLimit, BottomLimit)
	self.global_position = new_position
	
	UpdateCameraEdges()

func UpdateCameraEdges():
	#var viewport_rect: Rect2 = get_viewport_rect()
	var top_left_global_position: Vector2 = self.global_position
	var bottom_right_global_position: Vector2 = self.global_position + CameraSize
	
	#var top_left_local_position: Vector2 = viewport_rect.position
	#var bottom_right_local_position: Vector2 = viewport_rect.end
	
	var top_left_tile: Vector2i  = GroundGrid.local_to_map(top_left_global_position)
	#Without - Vector2i(1,1), it would get the tile that starts at the end of the screen, 
	#which would be the next bottom-right tile
	var bottom_right_tile: Vector2i = GroundGrid.local_to_map(bottom_right_global_position) - Vector2i(1,1)
	
	TopEdge = top_left_tile.y +2
	LeftEdge = top_left_tile.x +2
	BottomEdge = bottom_right_tile.y -2
	RightEdge = bottom_right_tile.x -2

func CheckCameraEdge(tile : Vector2i) -> bool:
	if tile.y < TopEdge:
		return true
	elif tile.x < LeftEdge:
		return true
	elif tile.y > BottomEdge:
		return true
	elif tile.x > RightEdge:
		return true
	
	return false

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
