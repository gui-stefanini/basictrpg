extends PanelContainer
##############################################################
#                      0.0 Signals                           #
##############################################################
signal action_selected(action: Action)

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var ActionButtonScene: PackedScene
@export var MyVBoxContainer: VBoxContainer

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func HideMenu():
	for button in MyVBoxContainer.get_children():
		button.queue_free()
	hide()

func ShowMenu(unit: Unit):
	for button in MyVBoxContainer.get_children():
		button.queue_free()
	
	var actions = unit.Data.Actions
	actions.sort_custom(func(a, b): 
		return a.Type < b.Type
		)
	
	for action in actions:
		var new_button = ActionButtonScene.instantiate()
		new_button.text = action.Name
		MyVBoxContainer.add_child(new_button)
		
		new_button.pressed.connect(_on_action_button_pressed.bind(action))
		if action is MoveAction and unit.HasMoved:
			new_button.disabled = true
		if action is not MoveAction and action is not WaitAction and unit.HasActed:
			new_button.disabled = true
	
	global_position = unit.global_position + Vector2(-8, -20)
	
	UiFunctions.ClampUI(self)
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_action_button_pressed(action:Action):
	hide()
	action_selected.emit(action)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	UiFunctions.SetMouseIgnore(self)
	UiFunctions.SetMouseIgnore(MyVBoxContainer)
