extends PanelContainer

signal action_selected(action: Action)

@export var ActionButtonScene: PackedScene
@export var MyVBoxContainer: VBoxContainer

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

func _on_action_button_pressed(action:Action):
	hide()
	action_selected.emit(action)

func _ready() -> void:
	UiFunctions.SetMouseIgnore(self)
	UiFunctions.SetMouseIgnore(MyVBoxContainer)
