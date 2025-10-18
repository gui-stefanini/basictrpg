class_name PreparationMenu
extends PanelContainer

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var UnitButtonScene : PackedScene
@export var UnitBoxContainer : VBoxContainer
@export var UnitCountLabel : Label

var MyGameManager: GameManager

######################
#     SCRIPT-WIDE    #
######################

var UnitCount : int
var SelectedUnits : Array[CharacterData]

var AllButtons: Array[UnitButton]
var SelectedButtons: Array[UnitButton]
var CurrentButton : UnitButton

##############################################################
#                      2.0 Functions                         #
##############################################################

func Initialize(manager: GameManager):
	SelectedUnits.clear()
	MyGameManager = manager
	UnitCount = manager.CurrentLevel.PlayerSpawns.size()
	SetUnitButtons()
	UpdateUnitCountLabel()

func ShowScreen():
	ConnectInputSignals()
	MyGameManager.ClearInputSignals()
	var center_position: Vector2 = MyGameManager.MyGameCamera.global_position + (MyGameManager.MyGameCamera.CameraSize / 2)
	global_position = center_position - Vector2(36, 32)
	show()

func HideScreen():
	ClearInputSignals()
	MyGameManager.ConnectInputSignals()
	hide()

func ConnectInputSignals():
	InputManager.confirm_pressed.connect(_on_confirm_pressed)
	InputManager.start_pressed.connect(_on_start_pressed)
	InputManager.direction_pressed.connect(_on_direction_pressed)

func ClearInputSignals():
	InputManager.confirm_pressed.disconnect(_on_confirm_pressed)
	InputManager.start_pressed.disconnect(_on_start_pressed)
	InputManager.direction_pressed.disconnect(_on_direction_pressed)

func SetUnitButtons():
	for character in GameData.PlayerArmy:
		var new_button : UnitButton = UnitButtonScene.instantiate()
		new_button.Character = character
		new_button.SetInfo()
		
		UnitBoxContainer.add_child(new_button)
		AllButtons.append(new_button)
	
	CurrentButton = AllButtons[0]
	CurrentButton.HoverColor.visible = true

func SelectButton(button: UnitButton):
	SelectedButtons.append(button)
	SelectedUnits.append(button.Character)
	button.UpdateSelection(SelectedUnits.size())

func UnselectButton(button : UnitButton):
	SelectedButtons.erase(button)
	button.UpdateSelection(-1, false)
	SelectedUnits.erase(button.Character)

func UpdateUnitCountLabel():
	UnitCountLabel.text = "Units Selected: %d/%d" % [SelectedUnits.size(), UnitCount]

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_confirm_pressed():
	if CurrentButton.MyButton.button_pressed == false:
		if SelectedUnits.size() < UnitCount:
			SelectButton(CurrentButton)
			UpdateUnitCountLabel()
		else:
			var previous_button = SelectedButtons.back()
			UnselectButton(previous_button)
			SelectButton(CurrentButton)
	else:
		UnselectButton(CurrentButton)
		UpdateUnitCountLabel()

func _on_start_pressed():
	if SelectedUnits.size() > 0:
		HideScreen()
		MyGameManager.StartGame()

func _on_direction_pressed(direction: Vector2i):
	if direction.y == 0:
		return
	var current_selection: int = AllButtons.find(CurrentButton)
	var new_selection: int
	var last_selection: int = AllButtons.size() - 1
	
	new_selection = current_selection + direction.y
	if new_selection > last_selection:
		new_selection = 0
	
	CurrentButton.HoverColor.visible = false
	CurrentButton = AllButtons[new_selection]
	CurrentButton.HoverColor.visible = true

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
