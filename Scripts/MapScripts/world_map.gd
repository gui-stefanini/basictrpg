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
	
	if CurrentLocation.MyLevelData != null:
		var level_data = CurrentLocation.MyLevelData
		
		LevelInfoPanel.global_position = CurrentLocation.global_position + Vector2(0,16)
		
		LevelNameLabel.text = " %s " % [level_data.LevelName]
		if level_data.Cleared == true:
			LevelNameLabel.text += "- Clear "
		LevelObjectiveLabel.text = " %s " % [level_data.LevelObjective]
		PlayerCountLabel.text = " Player Units: %d " % [level_data.PlayerCount]
		
		UiFunctions.call_deferred("ClampUI", LevelInfoPanel)
		LevelInfoPanel.show()
	
	elif CurrentLocation.MyEventData != null:
		var event_data = CurrentLocation.MyEventData
		
		if event_data.Cleared == true:
			SelectedLocation = null
			return
		
		EventNameLabel.text = event_data.EventName
		EventTextLabel.text = event_data.EventDescription
		
		EventPanel.show()

func ClearEventPanel():
	EventPanel.hide()
	EventNameLabel.text = ""
	EventTextLabel.text = ""

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_confirm_pressed():
	if LevelInfoPanel.is_visible_in_tree():
		GameData.CurrentLevel = SelectedLocation.MyLevelData
		GameData.SelectedLevelScene = SelectedLocation.MyLevelData.LevelScene
		SceneManager.ChangeSceneGame()
	
	elif EventPanel.is_visible_in_tree():
		SelectedLocation.MyEventData.play_event()
		ClearEventPanel()
		SelectedLocation.UpdateSprite()
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
		if CurrentLocation.LeftLocation != null:
			CurrentLocation = CurrentLocation.LeftLocation
	
	elif direction.x == 1:
		if CurrentLocation.RightLocation != null:
			CurrentLocation = CurrentLocation.RightLocation
	
	elif direction.y == -1:
		if CurrentLocation.UpLocation != null:
			CurrentLocation = CurrentLocation.UpLocation
	
	elif direction.y == 1:
		if CurrentLocation.DownLocation != null:
			CurrentLocation = CurrentLocation.DownLocation
	
	#var current_level_index = Locations.find(CurrentLocation)
	#var new_level_index = GeneralFunctions.ClampIndexInArray(current_level_index, direction.x, Locations)
	#CurrentLocation = Locations[new_level_index]
	
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
