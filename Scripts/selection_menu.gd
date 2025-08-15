extends Control

@export var LevelSelectionContainer : HBoxContainer
@export var UnitCustomizationContainer : VBoxContainer
@export var UnitInfoPanel : PanelContainer
@export var StartLevelButton : Button
@export var Level1Scene: PackedScene
@export var Level2Scene: PackedScene

@export var PlayerClasses: Array[UnitData]

var SelectedLevelPath: String = ""
var SelectedUnits: Array = []
var RequiredUnitCount: int = 0

func SelectLevel(level_scene: PackedScene):
	SelectedLevelPath = level_scene.resource_path
	print("Selected level: " + SelectedLevelPath)
	
	var level_instance = level_scene.instantiate()
	RequiredUnitCount = level_instance.PlayerSpawns.size()
	level_instance.queue_free()
	
	print("This level requires " + str(RequiredUnitCount) + " player units.")
	
	UpdateUnitCustomizationUI()
	
	SelectedUnits.clear()
	StartLevelButton.disabled = true

func UpdateUnitCustomizationUI():
	for child in UnitCustomizationContainer.get_children():
		child.queue_free()
	
	SelectedUnits.resize(RequiredUnitCount)
	
	for i in range(RequiredUnitCount):
		var slot_container = HBoxContainer.new()
		
		var slot_label = Label.new()
		slot_label.text = "Unit %d: " % (i + 1)
		
		var class_selector = OptionButton.new()
		class_selector.add_item("Select a Class")
		
		for j in range(PlayerClasses.size()):
			var unit_data = PlayerClasses[j]
			class_selector.add_item(unit_data.Name)
		
		# Connect the signal with bind to pass the slot index 'i'
		class_selector.item_selected.connect(_on_class_selected.bind(i))
		
		slot_container.add_child(slot_label)
		slot_container.add_child(class_selector)
		UnitCustomizationContainer.add_child(slot_container)

func _on_class_selected(item_index: int, unit_slot_index: int):
	
	if item_index == 0:
		SelectedUnits[unit_slot_index] = null
		_CheckSelectionsComplete()
		return
	
	var class_array_index = item_index - 1
	var selected_class = PlayerClasses[class_array_index]
	
	SelectedUnits[unit_slot_index] = selected_class
	print("Unit slot %d set to %s" % [unit_slot_index + 1, selected_class.Name])
	
	_CheckSelectionsComplete()

func _CheckSelectionsComplete():
	for unit in SelectedUnits:
		if not unit:
			StartLevelButton.disabled = true
			return 
	
	StartLevelButton.disabled = false
	print("All units selected. Ready to start.")

func _on_level_1_button_pressed() -> void:
	SelectLevel(Level1Scene)

func _on_level_2_button_pressed() -> void:
	SelectLevel(Level2Scene)

func _ready():
	UnitInfoPanel.hide()
	StartLevelButton.disabled = true
	
