class_name UnitButton
extends Control

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var MyButton : CheckButton
@export var Portrait : TextureRect
@export var HoverColor : ColorRect
var Character : CharacterData

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func SetInfo():
	MyButton.text = Character.Name
	Portrait.texture = Character.Portrait

func UpdateSelection(array_position: int, select : bool = true):
	if select == true:
		MyButton.text = "%s %d" % [Character.Name, array_position]
	else:
		MyButton.text = Character.Name
	
	MyButton.button_pressed = select

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
