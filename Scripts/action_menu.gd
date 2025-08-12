extends PanelContainer

signal action_selected(action: UnitData.Action)

@export var ActionButtonScene: PackedScene
@export var MyVBoxContainer: VBoxContainer

func ShowMenu(unit: Unit):
	for button in MyVBoxContainer.get_children():
		button.queue_free()
	
	for action in unit.Data.Actions:
		var new_button = ActionButtonScene.instantiate()
		new_button.text = UnitData.Action.keys()[action].capitalize()
		MyVBoxContainer.add_child(new_button)
		
		new_button.pressed.connect(_on_action_button_pressed.bind(action))
		if action == UnitData.Action.MOVE and unit.HasMoved:
			new_button.disabled = true
		if action != UnitData.Action.MOVE and action != UnitData.Action.WAIT and unit.HasActed:
			new_button.disabled = true
	
	global_position = unit.global_position + Vector2(-8, -20)
	show()

func _on_action_button_pressed(action: UnitData.Action):
	hide()
	action_selected.emit(action)
