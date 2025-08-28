extends Node

##############################################################
#                      0.0 Signals                           #
##############################################################

signal confirm_pressed
signal cancel_pressed
signal info_pressed
signal start_pressed
signal left_trigger_pressed
signal right_trigger_pressed
signal direction_pressed(direction: Vector2i)
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

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	if not event.is_pressed():
		return
	
	if Input.is_action_just_pressed("confirm"):
		confirm_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	
	if Input.is_action_just_pressed("cancel"):
		cancel_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	
	if Input.is_action_just_pressed("info"):
		info_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	
	if Input.is_action_just_pressed("start"):
		start_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	
	if Input.is_action_just_pressed("left_trigger"):
		left_trigger_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	
	if Input.is_action_just_pressed("right_trigger"):
		right_trigger_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	
	var direction := Vector2i.ZERO
	if Input.is_action_just_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_just_pressed("move_down"):
		direction.y = 1
	elif Input.is_action_just_pressed("move_left"):
		direction.x = -1
	elif Input.is_action_just_pressed("move_right"):
		direction.x = 1
	if direction != Vector2i.ZERO:
		direction_pressed.emit(direction)
		get_viewport().set_input_as_handled()
		return
