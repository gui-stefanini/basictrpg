class_name DefendLevelManager
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

@export var DefendTiles: Array[Vector2i]
@export var TurnLimit: int

##############################################################
#                      2.0 Functions                         #
##############################################################

func LevelSet():
	if not LevelHighlightLayer: return
	
	for tile in DefendTiles:
		# Draws the yellow highlight tile (Source ID 1, Atlas Coords 3,0)
		LevelHighlightLayer.set_cell(tile, 1, Vector2i(3, 0))
	
	request_dialogue.emit(LevelDialogue)

func TurnEnded(turn_number: int):
	match turn_number:
		TurnLimit:
			print("defense successful")
			victory.emit()

func UnitTurnEnded(unit: Unit, unit_tile: Vector2i):
	if unit.Faction == Unit.Factions.ENEMY:
		if unit_tile in DefendTiles:
			print("%s has breached the defenses!" % unit.Data.Name)
			defeat.emit()

func UnitSpawned(unit: Unit):
	if unit.Faction == Unit.Factions.ENEMY:
		unit.MyAI.TargetTiles = DefendTiles

func UnitDied(unit: Unit):
	print("%s has been defeated!" % unit.Data.Name)
	
	if UnitManager.PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()
		return

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
