class_name Level2Manager
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

##############################################################
#                      3.0 Signal Functions                  #
##############################################################
func _on_level_set():
	if not LevelHighlightLayer: return
	
	for tile in EscapeTiles:
		# Draws the yellow highlight tile (Source ID 1, Atlas Coords 3,0)
		LevelHighlightLayer.set_cell(tile, 1, Vector2i(3, 0))

func _on_turn_started(turn_number: int):
	var reinforcements : Array[SpawnInfo]
	match turn_number:
		3:
			reinforcements.append(EnemyReinforcements[0])
			reinforcements.append(EnemyReinforcements[1])
		5:
			reinforcements.append(EnemyReinforcements[2])
			reinforcements.append(EnemyReinforcements[3])
			reinforcements.append(EnemyReinforcements[4])
	
	request_spawn.emit(reinforcements)

func _on_unit_turn_ended(unit: Unit, unit_tile: Vector2i):
	if unit.Faction == Unit.Factions.PLAYER:
		if unit_tile in EscapeTiles:
			print("%s has escaped!" % unit.name)
			victory.emit()

func _on_unit_died(unit: Unit):
	print("%s has been defeated!" % unit.name)
	
	if PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
