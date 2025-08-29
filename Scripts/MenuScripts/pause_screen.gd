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
@export var ObjectiveLabel : Label
######################
#     SCRIPT-WIDE    #
######################
var MyGameManager: GameManager
##############################################################
#                      2.0 Functions                         #
##############################################################
func ShowScreen(manager: GameManager, objective_text: String):
	MyGameManager = manager
	MyGameManager.ClearInputSignals()
	InputManager.start_pressed.connect(HideScreen)
	
	get_tree().paused = true
	ObjectiveLabel.text = "Objective: %s" % [objective_text]
	show()

func HideScreen():
	InputManager.start_pressed.disconnect(HideScreen)
	MyGameManager.ConnectInputSignals()
	MyGameManager = null
	
	hide()
	get_tree().paused = false
	
##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	restart_requested.emit()
	hide()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	GameData.reset_data()
	GameData.restart_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
