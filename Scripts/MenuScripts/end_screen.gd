extends CanvasLayer
##############################################################
#                      0.0 Signals                           #
##############################################################
signal restart_requested

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var MessageLabel : Label
@export var RestartButton : Button
######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func ShowEndScreen(is_victory: bool):
	if is_victory:
		MessageLabel.text = "You Win!"
	else:
		MessageLabel.text = "Game Over"
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_restart_button_pressed():
	restart_requested.emit()

func _on_menu_button_pressed() -> void:
	GameData.reset_data()
	GameData.restart_game()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
