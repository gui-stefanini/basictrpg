class_name ProtectLevelManager
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

@export var ProtectedUnits: Array[Unit]
@export var ProtectAll: bool

##############################################################
#                      2.0 Functions                         #
##############################################################

func LevelSet():
	for unit in UnitManager.OpposingUnits:
		unit.MyAI.TargetUnits = ProtectedUnits
	
	request_dialogue.emit(LevelDialogue)

func UnitSpawned(unit: Unit):
	if unit.Affiliation == Unit.Affiliations.OPPOSING:
		unit.MyAI.TargetUnits = ProtectedUnits

func UnitDied(unit: Unit):
	print("%s has been defeated!" % unit.Data.Name)
	
	if ProtectedUnits.has(unit):
		if ProtectAll == true:
			print("You failed to protect the target")
			defeat.emit()
		
		else:
			ProtectedUnits.erase(unit)
			for opponent in UnitManager.OpposingUnits:
				if opponent.MyAI.TargetUnits.has(unit):
					opponent.MyAI.TargetUnits.erase(unit)
			if ProtectedUnits.is_empty():
				print("You failed to protect the targets")
				defeat.emit()
	
	if UnitManager.PlayerUnits.is_empty():
		print("All player units defeated!")
		defeat.emit()
	
	elif UnitManager.EnemyUnits.is_empty():
		print("All enemies defeated!")
		victory.emit()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
