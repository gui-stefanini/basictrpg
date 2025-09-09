class_name LocationData

extends Resource

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

@export var Name: String

@export var Locked: bool = true
@export var Cleared: bool = false
@export var Repeatable: bool = false

@export var UnlockableLocations: Array[String]
@export var LockableLocations: Array[String]
##############################################################
#                      2.0 Functions                         #
##############################################################

func ClearLocationData():
	if Cleared == true:
		return
	
	Cleared = true
	
	for location_name in UnlockableLocations:
		var location: LocationData = LocationList.get(location_name)
		location.Locked = false
	
	for location_name in LockableLocations:
		var location: LocationData = LocationList.get(location_name)
		location.Locked = true

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
