extends CanvasLayer

##############################################################
#                      0.0 Signals                           #
##############################################################
signal screen_closed

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var UnitSprite: Sprite2D
@export var NameLabel: Label
@export var HPLabel: Label
@export var AttackLabel: Label
@export var MoveLabel: Label
@export var RangeLabel: Label
@export var StatusContainer: VBoxContainer
@export var AbilityContainer: VBoxContainer
@export var ActionContainer: VBoxContainer
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
	PlayerUnits = game_manager.PlayerUnits
	EnemyUnits = game_manager.EnemyUnits
	AllUnits = game_manager.PlayerUnits + game_manager.EnemyUnits
	game_manager.unit_spawned.connect(_on_unit_spawned)
	game_manager.unit_removed.connect(_on_unit_removed)
	
	game_manager.cancel_passed.connect(_on_input_received.bind("close"))
	game_manager.info_passed.connect(_on_input_received.bind("close"))
	game_manager.right_trigger_passed.connect(_on_input_received.bind("next"))
	game_manager.left_trigger_passed.connect(_on_input_received.bind("previous"))

func ShowScreen(unit_to_show: Unit):
	CurrentUnit = unit_to_show
	CurrentUnitIndex = AllUnits.find(CurrentUnit)
	
	UpdatePanel()
	show()

func HideScreen():
	hide()
	screen_closed.emit()

func ClearContainer(container: VBoxContainer):
	for child in container.get_children():
		child.queue_free()

func UpdatePanel():
	if not is_instance_valid(CurrentUnit):
		HideScreen()
		return
	
	# --- Left Column ---
	UnitSprite.texture = CurrentUnit.Data.ClassSpriteSheet
	UnitSprite.hframes = CurrentUnit.Data.Hframes
	UnitSprite.vframes = CurrentUnit.Data.Vframes
	UnitSprite.frame = 0 # Frame 0 as requested
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
	
	# --- Right Column (Dynamic Lists) ---
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

func UpdateCursor(manager: GameManager):
	var unit_tile: Vector2i = manager.GroundGrid.local_to_map(CurrentUnit.global_position)
	manager.UpdateCursor(unit_tile)
##############################################################
#                      3.0 Signal Functions                  #
##############################################################
func _on_input_received(manager: GameManager, action: String):
	if not visible:
		return
	
	match action:
		"close":
			HideScreen()
		"next":
			CurrentUnitIndex = (CurrentUnitIndex + 1) % AllUnits.size()
			CurrentUnit = AllUnits[CurrentUnitIndex]
			UpdateCursor(manager)
			UpdatePanel()
		"previous":
			CurrentUnitIndex = (CurrentUnitIndex - 1 + AllUnits.size()) % AllUnits.size()
			CurrentUnit = AllUnits[CurrentUnitIndex]
			UpdateCursor(manager)
			UpdatePanel()

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
