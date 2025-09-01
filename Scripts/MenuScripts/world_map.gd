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
@export var Levels: Array[MapLevel]

@export var LevelInfoPanel: PanelContainer
@export var LevelNameLabel: Label
@export var LevelObjectiveLabel: Label
@export var PlayerCountLabel: Label

@export var GameScene: PackedScene

######################
#     SCRIPT-WIDE    #
######################

var CurrentLevel: MapLevel
var SelectedLevel: MapLevel

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

func SelectLevel():
	SelectedLevel = CurrentLevel
	
	LevelInfoPanel.global_position = CurrentLevel.global_position + Vector2(0,16)
	
	LevelNameLabel.text = " %s " % [CurrentLevel.LevelName]
	LevelObjectiveLabel.text = " %s " % [CurrentLevel.LevelObjective]
	PlayerCountLabel.text = " Player Units: %d " % [CurrentLevel.PlayerCount]
	
	UiFunctions.call_deferred("ClampUI", LevelInfoPanel)
	LevelInfoPanel.show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_confirm_pressed():
	if LevelInfoPanel.is_visible_in_tree():
		GameData.SelectedLevel = SelectedLevel.LevelScene
		SceneManager.ChangeSceneGame()
	
	else:
		SelectLevel()


func _on_cancel_pressed():
	if LevelInfoPanel.is_visible_in_tree():
		LevelInfoPanel.hide()

func _on_start_pressed():
	SceneManager.ChangeSceneMainMenu()

func _on_direction_pressed(direction: Vector2i):
	if LevelInfoPanel.is_visible_in_tree():
		return
	
	if direction.y != 0:
		return
	
	var current_level_index = Levels.find(CurrentLevel)
	var new_level_index = GeneralFunctions.ClampIndexInArray(current_level_index, direction.x, Levels)
	CurrentLevel = Levels[new_level_index]
	
	Player.global_position = CurrentLevel.global_position

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	ConnectInputSignals()
	CurrentLevel = Levels[0]
	Player.global_position = Levels[0].global_position


func _exit_tree() -> void:
	ClearInputSignals()
