class_name Level
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
@export var GroundGrid: TileMapLayer
@export var HighlightLayer: TileMapLayer
@export var CursorHighlightLayer: TileMapLayer
@export var LevelHighlightLayer: TileMapLayer
@export var MyLevelManager: LevelManager
@export var PlayerSpawns: Array[SpawnInfo]
@export var EnemySpawns: Array[SpawnInfo]

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
