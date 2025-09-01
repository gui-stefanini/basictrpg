extends Control

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var UnitSelectionSlotScene : PackedScene
var CurrentLevel : Level

######################
#     SCRIPT-WIDE    #
######################

var PlayerCount: int
var SpawnPositions : Array[Vector2i]

##############################################################
#                      2.0 Functions                         #
##############################################################

func SetLevel():
	CurrentLevel = GameData.selected_level.instantiate()
	add_child(CurrentLevel)
	
	PlayerCount = CurrentLevel.PlayerSpawns.size()
	for spawn_info in CurrentLevel.PlayerSpawns:
		SpawnPositions.append(spawn_info.Position)


##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	SetLevel()
