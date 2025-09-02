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
@export var TestCharacter: CharacterData
######################
#     SCRIPT-WIDE    #
######################

@export var PlayerUnits: Array[CharacterData]

@export var CurrentLevel: MapLevel
@export var ClearedLevels: Array[MapLevel]
var SelectedLevelScene: PackedScene

##############################################################
#                      2.0 Functions                         #
##############################################################

func ClearLevel():
	ClearedLevels.append(CurrentLevel)

func ResetLevelData():
	CurrentLevel = null
	SelectedLevelScene = null

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
