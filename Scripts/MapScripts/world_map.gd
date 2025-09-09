extends Node2D

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var Player: Node2D
@export var Locations: Array[MapLocation]

@export var LevelInfoPanel: PanelContainer
@export var LevelNameLabel: Label
@export var LevelObjectiveLabel: Label
@export var PlayerCountLabel: Label

@export var EventPanel: NinePatchRect
@export var EventNameLabel: Label
@export var EventTextLabel: Label

@export var GameScene: PackedScene

@export var MapBGM: AudioStream

######################
#     SCRIPT-WIDE    #
######################

var CurrentLocation: MapLocation
var SelectedLocation: MapLocation

##############################################################
#                      2.0 Functions                         #
##############################################################

func ConnectInputSignals():
	InputManager.confirm_pressed.connect(_on_confirm_pressed)
	InputManager.cancel_pressed.connect(_on_cancel_pressed)
	InputManager.start_pressed.connect(_on_start_pressed)
	InputManager.direction_pressed.connect(_on_direction_pressed)

func ClearInputSignals():
	InputManager.confirm_pressed.disconnect(_on_confirm_pressed)
	InputManager.cancel_pressed.disconnect(_on_cancel_pressed)
	InputManager.start_pressed.disconnect(_on_start_pressed)
	InputManager.direction_pressed.disconnect(_on_direction_pressed)

func SetAudio():
	AudioManager.PlayBGM(MapBGM)

func SelectLevel():
	SelectedLocation = CurrentLocation
	
	if CurrentLocation.MyLocationData is LevelData:
		var level_data = CurrentLocation.MyLocationData
		
		LevelInfoPanel.global_position = CurrentLocation.global_position + Vector2(0,16)
		
		LevelNameLabel.text = " %s " % [level_data.Name]
		if level_data.Cleared == true:
			LevelNameLabel.text += "- Cleared "
		LevelObjectiveLabel.text = " %s " % [level_data.LevelObjective]
		PlayerCountLabel.text = " Player Units: %d " % [level_data.PlayerCount]
		
		UiFunctions.call_deferred("ClampUI", LevelInfoPanel)
		LevelInfoPanel.show()
	
	elif CurrentLocation.MyLocationData is EventData:
		var event_data = CurrentLocation.MyLocationData
		
		if event_data.Cleared == true and event_data.Repeatable == false:
			SelectedLocation = null
			return
		
		EventNameLabel.text = event_data.Name
		EventTextLabel.text = event_data.EventDescription
		
		EventPanel.show()

func ClearEventPanel():
	EventPanel.hide()
	EventNameLabel.text = ""
	EventTextLabel.text = ""

func UpdateLocations():
	for location in Locations:
		location.UpdateLocation()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_confirm_pressed():
	if LevelInfoPanel.is_visible_in_tree():
		GameData.CurrentLevel = SelectedLocation.MyLocationData
		GameData.SelectedLevelScene = SelectedLocation.MyLocationData.LevelScene
		SceneManager.ChangeSceneGame()
	
	elif EventPanel.is_visible_in_tree():
		SelectedLocation.MyLocationData.play_event()
		UpdateLocations()
		ClearEventPanel()
		SelectedLocation = null
	
	else:
		SelectLevel()

func _on_cancel_pressed():
	if LevelInfoPanel.is_visible_in_tree():
		LevelInfoPanel.hide()
		SelectedLocation = null
	
	elif EventPanel.is_visible_in_tree():
		ClearEventPanel()
		SelectedLocation = null

func _on_start_pressed():
	SceneManager.ChangeSceneMainMenu()

func _on_direction_pressed(direction: Vector2i):
	if LevelInfoPanel.is_visible_in_tree():
		return
	
	if direction.x == -1:
		if CurrentLocation.LeftLocation != null and CurrentLocation.LeftLocation.Locked == false:
			CurrentLocation = CurrentLocation.LeftLocation
	
	elif direction.x == 1:
		if CurrentLocation.RightLocation != null and CurrentLocation.RightLocation.Locked == false:
			CurrentLocation = CurrentLocation.RightLocation
	
	elif direction.y == -1:
		if CurrentLocation.UpLocation != null and CurrentLocation.UpLocation.Locked == false:
			CurrentLocation = CurrentLocation.UpLocation
	
	elif direction.y == 1:
		if CurrentLocation.DownLocation != null and CurrentLocation.DownLocation.Locked == false:
			CurrentLocation = CurrentLocation.DownLocation
	
	Player.global_position = CurrentLocation.global_position

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	ConnectInputSignals()
	CurrentLocation = Locations[0]
	Player.global_position = Locations[0].global_position
	SetAudio()

func _exit_tree() -> void:
	ClearInputSignals()


func _on_unlock_button_pressed() -> void:
	for location in Locations:
		location.MyLocationData.Locked = false
	UpdateLocations()
