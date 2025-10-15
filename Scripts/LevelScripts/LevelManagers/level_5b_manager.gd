extends ProtectLevelManager
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

func LevelSet():
	for unit in UnitManager.AllyUnits:
		ProtectedUnits.append(unit)
	
	for unit in UnitManager.OpposingUnits:
		unit.MyAI.TargetUnits = ProtectedUnits
	
	request_dialogue.emit(LevelDialogue)

func TurnStarted(turn_number: int):
	var reinforcements : Array[SpawnInfo]
	match turn_number:
		2:
			reinforcements.append(EnemyReinforcements[0])
			reinforcements.append(EnemyReinforcements[1])
			reinforcements.append(EnemyReinforcements[2])
	CallReinforcements(reinforcements)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
