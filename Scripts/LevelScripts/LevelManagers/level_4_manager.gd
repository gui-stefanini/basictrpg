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

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_level_set():
	if not LevelHighlightLayer: return
	
	for tile in DefendTiles:
		# Draws the yellow highlight tile (Source ID 1, Atlas Coords 3,0)
		LevelHighlightLayer.set_cell(tile, 1, Vector2i(3, 0))

func _on_turn_started(turn_number: int):
	var reinforcements : Array[SpawnInfo]
	match turn_number:
		2:
			reinforcements.append(EnemyReinforcements[0])
			reinforcements.append(EnemyReinforcements[1])
		3:
			reinforcements.append(EnemyReinforcements[2])
			reinforcements.append(EnemyReinforcements[3])
	request_spawn.emit(reinforcements)

func _on_turn_ended(turn_number: int):
	match turn_number:
		5:
			print("defense successful")
			victory.emit()

func _on_unit_turn_ended(unit: Unit, unit_tile: Vector2i):
	if unit.Faction == Unit.Factions.ENEMY:
		if unit_tile in DefendTiles:
			print("%s has breached the defenses!" % unit.Data.Name)
			defeat.emit()

func _on_unit_spawned(unit: Unit):
	if unit.Faction == Unit.Factions.PLAYER:
		PlayerUnits.append(unit)
	elif unit.Faction == Unit.Factions.ENEMY:
		EnemyUnits.append(unit)
		unit.MyAI.TargetTiles = DefendTiles

func _on_unit_died(unit: Unit):
	print("%s has been defeated!" % unit.Data.Name)
	
	if PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()
		return

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
