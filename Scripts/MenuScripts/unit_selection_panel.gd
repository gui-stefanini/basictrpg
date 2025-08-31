class_name UnitSelectionPanel
extends Control

##############################################################
#                      0.0 Signals                           #
##############################################################
signal selection_complete(level: PackedScene, units: Array[UnitData])
##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var UnitSlotScene: PackedScene
@export var AllClasses: Array[UnitData]

@export var UnitSlotsContainer: VBoxContainer
@export var StartLevelButton: Button

@export var InfoPanel: PanelContainer
@export var NameLabel: Label
@export var HPAttackLabel: Label
@export var MoveRangeLabel: Label
@export var AbilitiesLabel: Label
@export var ActionsLabel: Label

######################
#     SCRIPT-WIDE    #
######################
var CurrentLevel: PackedScene
var CurrentSlots: Array[Node] = []
var CurrentSelectionIndex: int = 0

##############################################################
#                      2.0 Functions                         #
##############################################################

func Initialize(level_scene: PackedScene):
	CurrentLevel = level_scene
	
	# Temporarily instantiate the level to find out how many player spawns it has.
	var level_instance = level_scene.instantiate()
	var number_of_slots = level_instance.PlayerSpawns.size()
	level_instance.queue_free() # We don't need the instance anymore.
	
	CreateUnitSlots(number_of_slots)
	StartLevelButton.disabled = false
	show()
	
	# Set initial focus on the first slot
	if not CurrentSlots.is_empty():
		CurrentSlots[0].grab_focus()
		_on_slot_selected(CurrentSlots[0])


func CreateUnitSlots(amount: int):
	for child in UnitSlotsContainer.get_children():
		child.queue_free()
	CurrentSlots.clear()
	
	for i in range(amount):
		var new_slot = UnitSlotScene.instantiate()
		new_slot.name = "UnitSlot" + str(i)
		new_slot.AllClasses = AllClasses
		UnitSlotsContainer.add_child(new_slot)
		CurrentSlots.append(new_slot)
		
		new_slot.class_changed.connect(_on_slot_selected.bind(new_slot))
		new_slot.focus_entered.connect(_on_slot_selected.bind(new_slot))


func UpdateInfoPanel(unit_data: UnitData):
	NameLabel.text = "Class: %s" % unit_data.Name
	HPAttackLabel.text = "HP: %d | ATK: %d" % [unit_data.BaseMaxHP, unit_data.BaseAttackPower]
	MoveRangeLabel.text = "Move Range: %d" % unit_data.BaseMoveRange
	
	var ability_names = ""
	for ability in unit_data.Abilities:
		ability_names += ability.Name + " "
	AbilitiesLabel.text = "Abilities: %s" % ability_names
	
	var action_names = ""
	for action in unit_data.Actions:
		action_names += action.Name + " "
	ActionsLabel.text = "Actions: %s" % action_names

##############################################################
#                      3.0 Signal Functions                  #
##############################################################
func _on_slot_selected(slot: Node):
	UpdateInfoPanel(slot.SelectedClass)
	CurrentSelectionIndex = CurrentSlots.find(slot)


func _on_start_level_button_pressed():
	var selected_units: Array[UnitData] = []
	for slot in CurrentSlots:
		selected_units.append(slot.SelectedClass)
	
	selection_complete.emit(CurrentLevel, selected_units)
	hide()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	StartLevelButton.disabled = true
	hide()
