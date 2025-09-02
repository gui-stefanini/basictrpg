extends CanvasLayer
##############################################################
#                      0.0 Signals                           #
##############################################################

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
		GameData.ClearLevel()
	else:
		MessageLabel.text = "Game Over"
	get_tree().paused = true
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_world_map_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.StopAudio()
	GameData.ResetLevelData()
	SceneManager.ChangeSceneWorldMap()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.StopAudio()
	GameData.ResetLevelData()
	SceneManager.ChangeSceneMainMenu()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
