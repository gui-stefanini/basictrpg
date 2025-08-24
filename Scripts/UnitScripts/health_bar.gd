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
@export var MyProgressBar : ProgressBar

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func update_health(current_hp: int, max_hp: int):
	MyProgressBar.max_value = max_hp
	MyProgressBar.value = current_hp

	var percentage = float(current_hp) / max_hp
	if percentage <= 0.33:
		MyProgressBar.get_theme_stylebox("fill").bg_color = Color.RED
	elif percentage <= 0.66:
		MyProgressBar.get_theme_stylebox("fill").bg_color = Color.ORANGE
	else:
		MyProgressBar.get_theme_stylebox("fill").bg_color = Color.LIME_GREEN

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	MyProgressBar.add_theme_stylebox_override("fill", MyProgressBar.get_theme_stylebox("fill").duplicate())
