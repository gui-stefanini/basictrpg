extends CanvasLayer

##############################################################
#                      0.0 Signals                           #
##############################################################
signal restart_requested
##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var MyTabContainer: TabContainer
@export var UnitList: ItemList
#UnitTab
@export var UnitSprite: Sprite2D
@export var NameLabel: Label
@export var HPLabel: Label
@export var AttackLabel: Label
@export var MoveLabel: Label
@export var RangeLabel: Label
@export var StatusContainer: VBoxContainer
@export var AbilityContainer: VBoxContainer
@export var ActionContainer: VBoxContainer
# Faction Colors
@export var PlayerUnitColor: Color
@export var EnemyUnitColor: Color
#LevelTab
@export var ObjectiveLabel: Label

var MyGameManager: GameManager
######################
#     SCRIPT-WIDE    #
######################
var PlayerUnits: Array[Unit] = []
var EnemyUnits: Array[Unit] = []
var AllUnits: Array[Unit] = []
var CurrentUnit: Unit
var CurrentUnitIndex: int = 0

##############################################################
#                      2.0 Functions                         #
##############################################################
func Initialize(game_manager: GameManager):
	MyGameManager = game_manager
	#AllUnits = game_manager.AllUnits.duplicate()
	
	PlayerUnits = game_manager.PlayerUnits.duplicate()
	EnemyUnits = game_manager.EnemyUnits.duplicate()
	AllUnits = game_manager.PlayerUnits.duplicate() + game_manager.EnemyUnits.duplicate()
	
	restart_requested.connect(game_manager._on_restart_requested)
	game_manager.unit_spawned.connect(_on_unit_spawned)
	game_manager.unit_removed.connect(_on_unit_removed)

func ConnectInputSignals():
	InputManager.cancel_pressed.connect(HideScreen)
	InputManager.info_pressed.connect(HideScreen)
	InputManager.start_pressed.connect(HideScreen)
	InputManager.left_trigger_pressed.connect(_on_trigger_pressed.bind(-1))
	InputManager.right_trigger_pressed.connect(_on_trigger_pressed.bind(1))
	InputManager.direction_pressed.connect(_on_direction_pressed)

func ClearInputSignals():
	InputManager.cancel_pressed.disconnect(HideScreen)
	InputManager.info_pressed.disconnect(HideScreen)
	InputManager.start_pressed.disconnect(HideScreen)
	InputManager.left_trigger_pressed.disconnect(_on_trigger_pressed.bind(-1))
	InputManager.right_trigger_pressed.disconnect(_on_trigger_pressed.bind(1))
	InputManager.direction_pressed.disconnect(_on_direction_pressed)

func ShowScreen(unit_to_show: Unit, start_tab: int):
	# Take control of the input
	MyGameManager.ClearInputSignals()
	ConnectInputSignals()
	
	# Set starting tab
	MyTabContainer.current_tab = start_tab
	
	# Populate UI
	PopulateUnitList()
	ObjectiveLabel.text = "Objective: %s" % MyGameManager.CurrentLevelManager.LevelObjective
	
	if unit_to_show == null:
		CurrentUnit = AllUnits[0]
		CurrentUnitIndex = 0
		UnitList.select(0)
	
	else:
		CurrentUnit = unit_to_show
		CurrentUnitIndex = AllUnits.find(CurrentUnit)
		UnitList.select(CurrentUnitIndex)
	
	UpdateUnitPanel()
	show()

func HideScreen():
	# Return control of the input
	ClearInputSignals()
	MyGameManager.ConnectInputSignals()
	
	hide()

func PopulateUnitList():
	UnitList.clear()
	for i in range(AllUnits.size()):
		var unit = AllUnits[i]
		UnitList.add_item(unit.name)
		# We store the actual unit node in the item's metadata
		var unit_index = UnitList.get_item_count() - 1
		UnitList.set_item_metadata(unit_index, unit)
		
		if unit.Faction == Unit.Factions.PLAYER:
			UnitList.set_item_custom_fg_color(i, PlayerUnitColor)
		else:
			UnitList.set_item_custom_fg_color(i, EnemyUnitColor)

func ClearContainer(container: VBoxContainer):
	for child in container.get_children():
		child.queue_free()

func UpdateUnitPanel():
	# --- Left Column ---
	UnitSprite.texture = CurrentUnit.Data.ClassSpriteSheet
	UnitSprite.hframes = CurrentUnit.Data.Hframes
	UnitSprite.vframes = CurrentUnit.Data.Vframes
	UnitSprite.frame = 0
	UnitSprite.material = CurrentUnit.Sprite.material.duplicate()
	var unit_faction = CurrentUnit.Faction
	match unit_faction:
		Unit.Factions.PLAYER:
			UnitSprite.material.set_shader_parameter("new_color", CurrentUnit.PlayerFactionColor)
		Unit.Factions.ENEMY:
			UnitSprite.material.set_shader_parameter("new_color", CurrentUnit.EnemyFactionColor)
	
	NameLabel.text = CurrentUnit.name
	HPLabel.text = "HP: %d/%d" % [CurrentUnit.CurrentHP, CurrentUnit.MaxHP]
	AttackLabel.text = "ATK: %d" % CurrentUnit.AttackPower
	MoveLabel.text = "MOV: %d" % CurrentUnit.MoveRange
	RangeLabel.text = "RNG: %d" % CurrentUnit.AttackRange
	
	# --- Right Column ---
	ClearContainer(StatusContainer)
	ClearContainer(AbilityContainer)
	ClearContainer(ActionContainer)
	
	# Populate Statuses
	for status in CurrentUnit.ActiveStatuses:
		var status_data = CurrentUnit.ActiveStatuses[status]
		var duration = status_data[Unit.StatusInfo.DURATION]
		if duration == -1: continue # Skip permanent statuses for now
		
		var status_name = Unit.Status.find_key(status)
		var new_label = Label.new()
		if duration == -1:
			new_label.text = "- %s" % [status_name]
		else:
			new_label.text = "- %s (%d turns)" % [status_name, duration]
		new_label.label_settings = NameLabel.label_settings # Reuse existing settings, any label would work
		StatusContainer.add_child(new_label)

	# Populate Abilities
	for ability in CurrentUnit.Data.Abilities:
		if ability and ability.Description != "":
			var new_label = Label.new()
			new_label.text = "- %s: %s" % [ability.Name, ability.Description]
			new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			new_label.label_settings = NameLabel.label_settings
			AbilityContainer.add_child(new_label)
			
	# Populate Actions
	for action in CurrentUnit.Data.Actions:
		if action and action.Description != "":
			var new_label = Label.new()
			new_label.text = "- %s: %s" % [action.Name, action.Description]
			new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			new_label.label_settings = NameLabel.label_settings
			ActionContainer.add_child(new_label)

func UpdateCursor():
	var unit_tile: Vector2i = MyGameManager.GroundGrid.local_to_map(CurrentUnit.global_position)
	MyGameManager.UpdateCursor(unit_tile)

func UpdateUnitSelection(index: int):
	UnitList.select(index)
	var selected_unit = UnitList.get_item_metadata(index)
	CurrentUnit = selected_unit
	UpdateUnitPanel()
	UpdateCursor()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_direction_pressed(direction: Vector2i):
	if MyTabContainer.current_tab != 0: # Only works on the "Units" tab
		return
	
	var current_selection_array = UnitList.get_selected_items()
	if current_selection_array.is_empty():
		UnitList.select(0)
		return
	
	var current_selection = current_selection_array[0]
	var new_selection = current_selection + direction.y
	
	# Clamp the selection to the list bounds
	var item_count = UnitList.get_item_count()
	new_selection = (current_selection + direction.y + item_count) % item_count
	
	UpdateUnitSelection(new_selection)

func _on_trigger_pressed(direction: int):
	var tab_count = MyTabContainer.get_tab_count()
	var current_tab = MyTabContainer.current_tab
	# This formula correctly wraps around in both directions
	var next_tab = (current_tab + direction + tab_count) % tab_count
	MyTabContainer.current_tab = next_tab

func _on_unit_spawned(unit: Unit):
	if unit.Faction == Unit.Factions.PLAYER:
		PlayerUnits.append(unit)
	elif unit.Faction == Unit.Factions.ENEMY:
		EnemyUnits.append(unit)
	AllUnits = PlayerUnits + EnemyUnits

func _on_unit_removed(unit: Unit):
	if unit in PlayerUnits:
		PlayerUnits.erase(unit)
	elif unit in EnemyUnits:
		EnemyUnits.erase(unit)
	AllUnits = PlayerUnits + EnemyUnits

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _on_restart_button_pressed() -> void:
	restart_requested.emit()
	hide()

func _on_menu_button_pressed() -> void:
	GameData.reset_data()
	GameData.restart_game()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
