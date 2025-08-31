extends Control
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var SelectionMenuScene: PackedScene
@export var TutorialScene: PackedScene
@export var ResolutionButton: OptionButton

######################
#     SCRIPT-WIDE    #
######################

var Resolutions: Array[Vector2i] = [
	Vector2i(1600, 960),
	Vector2i(1280, 768),
	Vector2i(640, 384)
]

##############################################################
#                      2.0 Functions                         #
##############################################################

func SetResolutions():
	for resolution in Resolutions:
		ResolutionButton.add_item("%d x %d" % [resolution.x, resolution.y])
	
	# Set the default selection to match the current window size
	var current_size = DisplayServer.window_get_size()
	for i in range(Resolutions.size()):
		if Resolutions[i] == current_size:
			ResolutionButton.select(i)
			return

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(SelectionMenuScene)

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_packed(TutorialScene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _on_resolution_button_item_selected(index: int) -> void:
	DisplayServer.window_set_size(Resolutions[index])

func _ready() -> void:
	SetResolutions()
