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

var BossUnit: Unit

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_level_set():
	BossUnit = EnemyUnits[0]
	EnemyUnits[0].IsBoss = true
	EnemyUnits[0].Sprite.material.set_shader_parameter("new_color", EnemyUnits[0].BossColor)

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
	print("%s has been defeated!" % unit.name)
	
	if PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()
		return
	
	if unit == BossUnit:
		print("%s, the boss, has been defeated!" % unit.name)
		victory.emit()
##############################################################
#                      4.0 Godot Functions                   #
##############################################################
