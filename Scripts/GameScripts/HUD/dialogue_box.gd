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
@export var TextLabel : Label
var MyGameManager : GameManager
######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################
func Initialize(game_manager: GameManager):
	MyGameManager = game_manager

func ConnectInputSignals():
	InputManager.confirm_pressed.connect(AdvanceText)
	InputManager.cancel_pressed.connect(AdvanceText)

func ClearInputSignals():
	InputManager.confirm_pressed.disconnect(AdvanceText)
	InputManager.cancel_pressed.disconnect(AdvanceText)

func DisplayText(text: String):
	MyGameManager.ClearInputSignals()
	TextLabel.text = text
	show()
	ConnectInputSignals()

func AdvanceText():
	TextLabel.text = ""
	ClearInputSignals()
	hide()
	MyGameManager.ConnectInputSignals()


##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
