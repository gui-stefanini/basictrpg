class_name Level3Manager
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

var BossUnits: Array[Unit]

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_level_set():
	for unit in EnemyUnits:
		if unit.Data.Boss == true:
			BossUnits.append(unit)

func _on_turn_started(turn_number: int):
	var reinforcements : Array[SpawnInfo]
	match turn_number:
		2:
			reinforcements.append(EnemyReinforcements[0])
			reinforcements.append(EnemyReinforcements[1])
		4:
			reinforcements.append(EnemyReinforcements[2])
			reinforcements.append(EnemyReinforcements[3])
		6:
			reinforcements.append(EnemyReinforcements[4])
			reinforcements.append(EnemyReinforcements[5])
	request_spawn.emit(reinforcements)

func _on_unit_died(unit: Unit):
	print("%s has been defeated!" % unit.Data.Name)
	
	if PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()
		return
	
	if unit in BossUnits:
		print("%s, a boss, has been defeated!" % unit.Data.Name)
		BossUnits.erase(unit)
		
		if BossUnits.is_empty():
			victory.emit()
##############################################################
#                      4.0 Godot Functions                   #
##############################################################
