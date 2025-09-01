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
@export var WorldMapScene : PackedScene
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

func _on_world_map_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.StopAudio()
	get_tree().change_scene_to_packed(WorldMapScene)

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
