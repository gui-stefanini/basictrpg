class_name UpgradeEventData

extends EventData

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

@export var UpgradedCharacter: CharacterData
@export var StatName: String
@export var StatValue: int

##############################################################
#                      2.0 Functions                         #
##############################################################

func play_event():
	if not GameData.PlayerArmy.has(UpgradedCharacter):
		return
	
	var value = UpgradedCharacter.get(StatName)
	value += StatValue
	UpgradedCharacter.set(StatName, value)
	
	if not UpgradedCharacter.InfoToSave.has(StatName):
		UpgradedCharacter.InfoToSave.append(StatName)
	
	ClearLocationData()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
