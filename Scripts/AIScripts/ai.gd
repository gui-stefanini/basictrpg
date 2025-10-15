class_name AI
extends Node

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

var Behavior : AIBehavior

######################
#     SCRIPT-WIDE    #
######################

var IsMobile: bool = true
var StayImmobile: bool = false
var IgnorePlayers: bool = false

var TargetTiles: Array[Vector2i]
var TargetUnits: Array[Unit]

var BehaviorSpecific: Dictionary = {}

##############################################################
#                      2.0 Functions                         #
##############################################################

func SetBehavior(behavior: AIBehavior):
	Behavior = behavior
	IsMobile = behavior.IsMobile
	StayImmobile = behavior.StayImmobile
	IgnorePlayers = behavior.IgnorePlayers
	
	Behavior.Initialize(self)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################


##############################################################
#                      4.0 Godot Functions                   #
##############################################################
