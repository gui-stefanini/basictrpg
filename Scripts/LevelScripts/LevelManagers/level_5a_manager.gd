extends DefendLevelManager

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

func TurnStarted(turn_number: int):
	var reinforcements : Array[SpawnInfo]
	match turn_number:
		2:
			reinforcements.append(EnemyReinforcements[0])
			reinforcements.append(EnemyReinforcements[1])
			reinforcements.append(EnemyReinforcements[2])
		3:
			reinforcements.append(EnemyReinforcements[3])
			reinforcements.append(EnemyReinforcements[4])
			reinforcements.append(EnemyReinforcements[5])
		5:
			reinforcements.append(EnemyReinforcements[6])
			reinforcements.append(EnemyReinforcements[7])
	CallReinforcements(reinforcements)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
