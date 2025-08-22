class_name Level1Manager
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

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################
func _on_unit_died(unit: Unit):
	print("%s has been defeated!" % unit.name)
	
	var remaining_players = 0
	for player in PlayerUnits:
		if not player.IsDead:
			remaining_players += 1
	
	var remaining_enemies = 0
	for enemy in EnemyUnits:
		if not enemy.IsDead:
			remaining_enemies += 1
	if remaining_players == 0:
		print("All player units defeated!")
		defeat.emit()
	elif remaining_enemies == 0:
		print("All enemies defeated!")
		victory.emit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
