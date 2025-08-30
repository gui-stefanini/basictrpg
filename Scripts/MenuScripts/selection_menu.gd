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
@export var GameManagerScene: PackedScene
@export var Level1Scene: PackedScene
@export var Level2Scene: PackedScene
@export var Level3Scene: PackedScene

@export var LevelSelectionContainer : HBoxContainer
@export var UnitCustomizationContainer : VBoxContainer
@export var StartLevelButton : Button
@export var UnitInfoPanel : PanelContainer
@export var NameLabel: Label
@export var HPAttackLabel: Label
#@export var AttackLabel: Label
@export var MoveRangeLabel: Label
#@export var AttackRangeLabel: Label
@export var AbilitiesLabel: Label
@export var ActionsLabel: Label
@export var UnitSelectionSlotScene: PackedScene

######################
#     SCRIPT-WIDE    #
######################
@export var PlayerClasses: Array[UnitData]
var SelectedLevel: PackedScene
var SelectedUnits: Array = [UnitData]
var RequiredUnitCount: int = 0

##############################################################
#                      2.0 Functions                         #
##############################################################

func UpdateUnitCustomizationUI():
	for child in UnitCustomizationContainer.get_children():
		child.queue_free()
	
	SelectedUnits.resize(RequiredUnitCount)
	
	for i in range(RequiredUnitCount):
		var new_slot = UnitSelectionSlotScene.instantiate()
		var slot_label = new_slot.get_node("Label")
		var class_selector = new_slot.get_node("OptionButton")
		
		slot_label.text = "Unit %d: " % (i + 1)
		
		class_selector.add_item("Select a Class")
		
		for j in range(PlayerClasses.size()):
			var unit_data = PlayerClasses[j]
			class_selector.add_item(unit_data.Name)
		
		# Connect the signal with bind to pass the slot index 'i'
		class_selector.item_selected.connect(_on_class_selected.bind(i))
		
		UnitCustomizationContainer.add_child(new_slot)

func SelectLevel(level_scene: PackedScene):
	SelectedUnits.clear()
	UpdateMenuInfoPanel(null)
	SelectedLevel = level_scene
	
	var level_instance = level_scene.instantiate()
	RequiredUnitCount = level_instance.PlayerSpawns.size()
	level_instance.queue_free()
	
	print("This level requires " + str(RequiredUnitCount) + " player units.")
	
	UpdateUnitCustomizationUI()
	
	StartLevelButton.disabled = true

func UpdateMenuInfoPanel(data: UnitData):
	if not data:
		UnitInfoPanel.hide()
		return
		
	NameLabel.text = data.Name
	HPAttackLabel.text = "ATK: %d   HP: %d" % [data.BaseAttackPower, data.BaseMaxHP]
	#AttackLabel.text = "ATK: " + str(data.BaseAttackPower)
	MoveRangeLabel.text = "MOV: %d  RNG: %d " % [data.BaseMoveRange, data.BaseAttackRange]
	#AttackRangeLabel.text = "RNG: " + str(data.BaseAttackRange)
	
	var abilities_text = "Abilities:"
	var actions_text = "Actions:"
	
	for ability in data.Abilities:
		if ability and ability.Description != "":
			abilities_text += "\n- %s: %s" % [ability.Name, ability.Description]
	
	for action in data.Actions:
		if action and action.Description != "":
			actions_text += "\n- %s: %s" % [action.Name, action.Description]
	
	AbilitiesLabel.text = abilities_text
	ActionsLabel.text = actions_text
	UnitInfoPanel.show()

func CheckSelectionsComplete():
	for unit in SelectedUnits:
		if not unit:
			StartLevelButton.disabled = true
			return 
	
	StartLevelButton.disabled = false
	print("All units selected. Ready to start.")

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_class_selected(item_index: int, unit_slot_index: int):
	if item_index == 0:
		SelectedUnits[unit_slot_index] = null
		UpdateMenuInfoPanel(null)
		CheckSelectionsComplete()
		return
	
	var class_array_index = item_index - 1
	var selected_class = PlayerClasses[class_array_index]
	
	SelectedUnits[unit_slot_index] = selected_class
	
	UpdateMenuInfoPanel(selected_class)
	
	CheckSelectionsComplete()

func _on_level_1_button_pressed() -> void:
	SelectLevel(Level1Scene)

func _on_level_2_button_pressed() -> void:
	SelectLevel(Level2Scene)

func _on_level_3_button_pressed() -> void:
	SelectLevel(Level3Scene)

func _on_start_level_button_pressed() -> void:
	GameData.selected_level = SelectedLevel
	GameData.player_units = SelectedUnits
	
	get_tree().change_scene_to_packed(GameManagerScene)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	UnitInfoPanel.hide()
	StartLevelButton.disabled = true
