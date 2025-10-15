class_name EscapeLevelManager
extends LevelManager
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
######################
#     SCRIPT-WIDE    #
######################
@export var EscapeTiles: Array[Vector2i]

##############################################################
#                      2.0 Functions                         #
##############################################################

func LevelSet():
	if not LevelHighlightLayer: return
	
	for tile in EscapeTiles:
		# Draws the yellow highlight tile (Source ID 1, Atlas Coords 3,0)
		LevelHighlightLayer.set_cell(tile, 1, Vector2i(3, 0))
	
	request_dialogue.emit(LevelDialogue)

func UnitTurnEnded(unit: Unit, unit_tile: Vector2i):
	if unit.Faction == Unit.Factions.PLAYER:
		if unit_tile in EscapeTiles:
			print("%s has escaped!" % unit.Data.Name)
			victory.emit()

func UnitDied(unit: Unit):
	print("%s has been defeated!" % unit.Data.Name)
	
	if UnitManager.PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
