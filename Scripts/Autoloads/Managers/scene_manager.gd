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

@export var MainMenuScene: PackedScene
@export var WorldMapScene: PackedScene
@export var GameManagerScene: PackedScene

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func ChangeSceneMainMenu():
	get_tree().paused = false
	get_tree().change_scene_to_packed(MainMenuScene)

func ChangeSceneWorldMap():
	get_tree().paused = false
	get_tree().change_scene_to_packed(WorldMapScene)

func ChangeSceneGame():
	get_tree().paused = false
	get_tree().change_scene_to_packed(GameManagerScene)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
