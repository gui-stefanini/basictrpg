class_name BossLevelManager
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
	
	request_dialogue.emit(LevelDialogue)

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
