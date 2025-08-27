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
var selected_level: PackedScene
#var selected_level: String = ""
var player_units: Array = [UnitData]

##############################################################
#                      2.0 Functions                         #
##############################################################

func restart_game():
	
	get_tree().paused = false
	get_tree().change_scene_to_packed(MainMenuScene)


func reset_data():
	selected_level = null
	player_units = []

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
