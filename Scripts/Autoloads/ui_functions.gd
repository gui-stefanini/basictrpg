extends Node
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
######################
#     SCRIPT-WIDE    #
######################
##############################################################
#                      2.0 Functions                         #
##############################################################

func ClampUI(ui_node: Control):
	var viewport_rect = ui_node.get_viewport_rect()
	var node_size = ui_node.size

	var node_pos = ui_node.global_position
	node_pos.x = clampf(node_pos.x, 0, viewport_rect.size.x - node_size.x)
	node_pos.y = clampf(node_pos.y, 0, viewport_rect.size.y - node_size.y)

	ui_node.global_position = node_pos

func ResetUI(ui_node: Control):
	ui_node.custom_minimum_size = Vector2(0,0)
	ui_node.reset_size()

func SetMouseIgnore(ui_node: Control):
	ui_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
