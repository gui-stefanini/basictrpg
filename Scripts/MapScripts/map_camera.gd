class_name MapCamera
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

var Background: TextureRect

######################
#     SCRIPT-WIDE    #
######################

var CameraSize: Vector2
var CameraSupposedPosition: Vector2

var TopLimit: float
var LeftLimit: float
var BottomLimit: float
var RightLimit: float

var TopEdge : float
var LeftEdge : float
var BottomEdge : float
var RightEdge : float

##############################################################
#                      2.0 Functions                         #
##############################################################

#func Initialize(background: TextureRect):
	#Background = background
	#CameraSize = get_viewport_rect().size
	#SetLimits()
#
#func SetLimits():
	#var map_rect : Rect2 = Background.get_global_rect()
	#
	#TopLimit = map_rect.position.y
	#LeftLimit = map_rect.position.x
	#BottomLimit = map_rect.end.y - CameraSize.y
	#RightLimit = map_rect.end.x - CameraSize.x
	#
	#TopEdge = TopLimit - (CameraSize.y/2)
	#LeftEdge = LeftLimit - (CameraSize.x/2)
	#BottomEdge = BottomLimit + (CameraSize.y/2)
	#RightEdge = RightLimit + (CameraSize.x/2)
	##UpdateCameraEdges()
#
#func MoveCamera(current_location: MapLocation, next_location: MapLocation):
	#var current_location_position: Vector2 = current_location.global_position
	#var next_location_position: Vector2 = next_location.global_position
	#
	#var camera_movement: Vector2 = next_location_position - current_location_position
	#
	#var new_position = self.global_position + camera_movement
	#new_position.x = clamp(new_position.x, LeftLimit, RightLimit)
	#new_position.y = clamp(new_position.y, TopLimit, BottomLimit)
	#self.global_position = new_position
#-------
#func UpdateCameraEdges():
	#var top_left_global_position: Vector2 = self.global_position
	#var bottom_right_global_position: Vector2 = self.global_position + CameraSize

#func MoveCamera(location : MapLocation):
	#var camera_movement: Vector2 = Vector2(0,0)
	#
	#if location.global_position.y < TopEdge:
		#camera_movement.y = location.global_position.y - TopEdge
	#if location.global_position.x < LeftEdge:
		#camera_movement.x = location.global_position.x - LeftEdge
	#if location.global_position.y > BottomEdge:
		#camera_movement.y = location.global_position.y - BottomEdge
	#if location.global_position.x > RightEdge:
		#camera_movement.x = location.global_position.x - RightEdge
	#
	#var new_position = self.global_position + camera_movement
	#new_position.x = clamp(new_position.x, LeftLimit, RightLimit)
	#new_position.y = clamp(new_position.y, TopLimit, BottomLimit)
	#self.global_position = new_position
	#
	#UpdateCameraEdges()
#
#func UpdateCameraEdges():
	#var top_left_global_position: Vector2 = self.global_position
	#var bottom_right_global_position: Vector2 = self.global_position + CameraSize
	#
	#TopEdge = top_left_global_position.y
	#LeftEdge = top_left_global_position.x
	#BottomEdge = bottom_right_global_position.y
	#RightEdge = bottom_right_global_position.x
#
#func CheckCameraEdge(location : MapLocation):
	#var move_camera : bool = false
	#
	#if location.global_position.y < TopEdge:
		#move_camera = true
	#elif location.global_position.x < LeftEdge:
		#move_camera = true
	#elif location.global_position.y > BottomEdge:
		#move_camera = true
	#elif location.global_position.x > RightEdge:
		#move_camera = true
	#
	#if move_camera == true:
		#MoveCamera(location)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
