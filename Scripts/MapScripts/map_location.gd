class_name MapLocation
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

@export var MyLevelData: LevelData
@export var MyEventData: EventData

@export var Sprite: Sprite2D

@export var LeftLocation: MapLocation
@export var RightLocation: MapLocation
@export var UpLocation: MapLocation
@export var DownLocation: MapLocation

######################
#     SCRIPT-WIDE    #
######################

@export var Locked: bool = true

##############################################################
#                      2.0 Functions                         #
##############################################################

func UpdateSprite():
	if MyLevelData != null:
		if MyLevelData.Cleared == true:
			Sprite.frame_coords = Vector2i(1,0)
			return
		Sprite.frame_coords = Vector2i(0,0)
	
	elif MyEventData != null:
		if MyEventData.Cleared == true:
			Sprite.frame_coords = Vector2i(1,1)
			return
		Sprite.frame_coords = Vector2i(0,1)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	UpdateSprite()
