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

##############################################################
#                      2.0 Functions                         #
##############################################################

func NavigateUp():
	var current_selection = MyItemList.get_selected_items()[0]
	# % gives the remain of the division. 
	# Ex: if there are 4 itens and you are on item 2: (2-1+4)%4 = 5%4 = 1 remain.
	var new_selection = (current_selection - 1 + MyItemList.item_count) % MyItemList.item_count
	MyItemList.select(new_selection)

func NavigateDown():
	var current_selection = MyItemList.get_selected_items()[0]
	var new_selection = (current_selection + 1) % MyItemList.item_count
	MyItemList.select(new_selection)

func HideMenu():
	MyItemList.clear()
	hide()

func ShowMenu(unit: Unit):
	MyItemList.clear()
	
	var actions = unit.Data.Actions
	actions.sort_custom(func(a, b): 
		return a.Type < b.Type
		)
	
	for i in range(actions.size()):
		var action = actions[i]
		MyItemList.add_item(action.Name)
		MyItemList.set_item_metadata(i, action)
		
		if action is MoveAction and unit.HasMoved:
			MyItemList.set_item_disabled(i, true)
		if action is not MoveAction and action is not WaitAction and unit.HasActed:
			MyItemList.set_item_disabled(i, true)
	
	MyItemList.select(0)
	MyItemList.grab_focus()
	
	global_position = unit.global_position + Vector2(-8, -20)
	
	UiFunctions.ClampUI(self)
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

#func _on_action_button_pressed(action:Action):
	#hide()
	#action_selected.emit(action)

func SelectAction():
	var selected_index = MyItemList.get_selected_items()[0]
	var selected_action = MyItemList.get_item_metadata(selected_index)
	action_selected.emit(selected_action)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	UiFunctions.SetMouseIgnore(self)
	UiFunctions.SetMouseIgnore(MyItemList)
