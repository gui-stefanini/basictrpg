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
@export var PlayerSprite: Sprite2D
@export var LevelNodes: Array[Node2D]
@export var MyUnitSelectionPanel: UnitSelectionPanel

@export var GameManagerScene: PackedScene
@export var LevelScenes: Array[PackedScene]
######################
#     SCRIPT-WIDE    #
######################

var CurrentSelectionIndex: int = 0
var IsPanelOpen: bool = false

##############################################################
#                      2.0 Functions                         #
##############################################################

func ConnectInputSignals() -> void:
	InputManager.direction_pressed.connect(_on_direction_pressed)
	InputManager.confirm_pressed.connect(_on_confirm_pressed)

func ClearInputSignals() -> void:
	InputManager.direction_pressed.disconnect(_on_direction_pressed)
	InputManager.confirm_pressed.disconnect(_on_confirm_pressed)

func UpdatePlayerPosition() -> void:
	var target_node = LevelNodes[CurrentSelectionIndex]
	PlayerSprite.global_position = target_node.global_position
	
##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_direction_pressed(direction: Vector2i) -> void:
	if IsPanelOpen: return
	
	if direction.x == 1: # Right
		CurrentSelectionIndex = (CurrentSelectionIndex + 1) % LevelNodes.size()
		UpdatePlayerPosition()
	elif direction.x == -1: # Left
		CurrentSelectionIndex = (CurrentSelectionIndex - 1 + LevelNodes.size()) % LevelNodes.size()
		UpdatePlayerPosition()

func _on_confirm_pressed() -> void:
	if IsPanelOpen: return
	
	IsPanelOpen = true
	MyUnitSelectionPanel.Initialize(LevelScenes[CurrentSelectionIndex])

func _on_selection_complete(level: PackedScene, units: Array[UnitData]) -> void:
	GameData.selected_level = level
	GameData.player_units = units
	
	get_tree().change_scene_to_packed(GameManagerScene)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	ConnectInputSignals()
	UpdatePlayerPosition()

func _exit_tree() -> void:
	ClearInputSignals()
