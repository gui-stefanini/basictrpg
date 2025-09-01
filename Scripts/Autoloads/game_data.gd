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
@export var TestLevel: PackedScene
@export var TestClass: UnitData
######################
#     SCRIPT-WIDE    #
######################

@export var PlayerUnits: Array[UnitData]

var SelectedLevel: PackedScene

##############################################################
#                      2.0 Functions                         #
##############################################################

func restart_game():
	
	get_tree().paused = false
	get_tree().change_scene_to_packed(MainMenuScene)

func reset_data():
	SelectedLevel = null

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
