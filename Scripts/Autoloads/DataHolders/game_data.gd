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

@export var PlayerArmy: Array[CharacterData]
@export var PlayerSquad: Array[CharacterData]

@export var CurrentLevel: LevelData
#@export var ClearedLevels: Array[LevelData]
var SelectedLevelScene: PackedScene

##############################################################
#                      2.0 Functions                         #
##############################################################

func ClearLevel():
	CurrentLevel.ClearLocationData()
	#ClearedLevels.append(CurrentLevel)

func ResetLevelData():
	CurrentLevel = null
	SelectedLevelScene = null

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
