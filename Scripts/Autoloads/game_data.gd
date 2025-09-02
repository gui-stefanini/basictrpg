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

@export var CurrentLevelIndex: int
@export var ClearedLevelsIndex: Array[int]
var SelectedLevelScene: PackedScene

##############################################################
#                      2.0 Functions                         #
##############################################################

func ClearLevel():
	ClearedLevelsIndex.append(CurrentLevelIndex)

func ResetLevelData():
	CurrentLevelIndex = -1
	SelectedLevelScene = null

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
