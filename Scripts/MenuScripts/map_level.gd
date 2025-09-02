class_name MapLevel
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

@export var LevelScene: PackedScene
@export var Sprite: Sprite2D

######################
#     SCRIPT-WIDE    #
######################

@export var LevelIndex: int
@export var LevelName: String
@export var LevelObjective: String
@export var PlayerCount: int
@export var Cleared: bool = false

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
func _ready() -> void:
	if GameData.ClearedLevelsIndex.has(LevelIndex):
		Cleared = true
		Sprite.frame = 1
		return
	Sprite.frame = 0
