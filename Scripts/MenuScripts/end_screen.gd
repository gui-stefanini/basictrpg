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
	get_tree().paused = true
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_restart_button_pressed():
	get_tree().paused = false
	AudioManager.StopAudio()
	restart_requested.emit()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.StopAudio()
	GameData.reset_data()
	GameData.restart_game()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
