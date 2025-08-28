class_name ActionMenu
extends PanelContainer
##############################################################
#                      0.0 Signals                           #
##############################################################
@warning_ignore("unused_signal")
signal action_selected(action: Action)

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var ActionButtonScene: PackedScene
@export var MyItemList: ItemList

######################
#     SCRIPT-WIDE    #
######################
@export var ValidSelectionColor: Color
@export var InvalidSelectionColor: Color
var ActiveUnit : Unit = null

##############################################################
#                      2.0 Functions                         #
##############################################################
func UpdateColor(index: int):
	var is_enabled = IsActionValid(index)
	print(is_enabled)
	if is_enabled:
		MyItemList.add_theme_color_override("font_selected_color", ValidSelectionColor)
	else:
		MyItemList.add_theme_color_override("font_selected_color", InvalidSelectionColor)

func NavigateUp():
	if MyItemList.get_selected_items().is_empty():
		MyItemList.select(0)
		return
	var current_selection = MyItemList.get_selected_items()[0]
	# % gives the remain of the division. 
	# Ex: if there are 4 itens and you are on item 2: (2-1+4)%4 = 5%4 = 1 remain.
	var new_selection = (current_selection - 1 + MyItemList.item_count) % MyItemList.item_count
	MyItemList.select(new_selection)
	UpdateColor(new_selection)

func NavigateDown():
	if MyItemList.get_selected_items().is_empty():
		MyItemList.select(0)
		return
	var current_selection = MyItemList.get_selected_items()[0]
	var new_selection = (current_selection + 1) % MyItemList.item_count
	MyItemList.select(new_selection)
	UpdateColor(new_selection)

func HideMenu():
	MyItemList.clear()
	ActiveUnit = null
	hide()

func ShowMenu(unit: Unit):
	MyItemList.clear()
	
	ActiveUnit = unit
	
	var actions = unit.Data.Actions
	actions.sort_custom(func(a, b): 
		return a.Type < b.Type
		)
	
	for i in range(actions.size()):
		var action = actions[i]
		MyItemList.add_item(action.Name)
		MyItemList.set_item_metadata(i, action)
		var is_enabled = IsActionValid(i)
		
		if not is_enabled:
			MyItemList.set_item_custom_fg_color(i, Color.DIM_GRAY)
	
	MyItemList.select(0)
	UpdateColor(0)
	
	global_position = unit.global_position + Vector2(-8, -20)
	
	UiFunctions.ClampUI(self)
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

#func _on_action_button_pressed(action:Action):
	#hide()
	#action_selected.emit(action)

func IsActionValid(index: int) -> bool:
	var action = MyItemList.get_item_metadata(index)
	
	var is_enabled = true
	
	if action is MoveAction and ActiveUnit.HasMoved:
		is_enabled = false
	if action is not MoveAction and action is not WaitAction and ActiveUnit.HasActed:
		is_enabled = false
	
	return is_enabled

func SelectAction():
	var selected_index = MyItemList.get_selected_items()[0]
	if IsActionValid(selected_index) == false:
		return
	
	var selected_action = MyItemList.get_item_metadata(selected_index)
	action_selected.emit(selected_action)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	UiFunctions.SetMouseIgnore(self)
	UiFunctions.SetMouseIgnore(MyItemList)
