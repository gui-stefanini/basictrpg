class_name Action
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
enum ActionTypes {MOVE, ATTACK, SPECIAL, WAIT}
@export var Type : ActionTypes
@export var Name: String = "Action"
@export_multiline var Description: String = ""

##############################################################
#                      2.0 Functions                         #
##############################################################

func connect_listeners(_owner: Unit):
	pass

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(_user: Unit, _manager: GameManager):
	pass # Child scripts will implement their own logic here.

func _check_target(_user: Unit, _manager: GameManager = null, _target = null) -> bool:
	return true

func _execute(_user: Unit, _manager: GameManager, _target = null, _simulation : bool = false) -> Variant:
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
