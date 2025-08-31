class_name UnitSelectionSlot
extends HBoxContainer
##############################################################
#                      0.0 Signals                           #
##############################################################
signal class_changed

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var ClassOptionButton: OptionButton

######################
#     SCRIPT-WIDE    #
######################
var AllClasses: Array[UnitData]
var SelectedClass: UnitData

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_class_option_button_item_selected(index: int):
	SelectedClass = AllClasses[index]
	class_changed.emit()

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	# Wait for AllClasses to be set by the parent node.
	
	for unit_class in AllClasses:
		ClassOptionButton.add_item(unit_class.Name)
	
	# Set the initial selection
	SelectedClass = AllClasses[0]
	ClassOptionButton.select(0)
	
