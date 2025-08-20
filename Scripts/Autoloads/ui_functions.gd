extends Node

func ClampUI(ui_node: Control):
	var viewport_rect = ui_node.get_viewport_rect()
	var node_size = ui_node.size

	var node_pos = ui_node.global_position
	node_pos.x = clampf(node_pos.x, 0, viewport_rect.size.x - node_size.x)
	node_pos.y = clampf(node_pos.y, 0, viewport_rect.size.y - node_size.y)

	ui_node.global_position = node_pos

func SetMouseIgnore(ui_node: Control):
	ui_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
