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

@export var HoldTimer: Timer

######################
#     SCRIPT-WIDE    #
######################

@export var FirstHoldTime: float = 0.5
@export var HoldTime: float = 0.1
var FirstHold: bool = true

enum Keys {NULL, CONFIRM, CANCEL, INFO, START, LEFT_TRIGGER, RIGHT_TRIGGER, UP, DOWN, LEFT, RIGHT}
var HeldKey : Keys = Keys.NULL

##############################################################
#                      2.0 Functions                         #
##############################################################

func PressLeftTrigger():
	left_trigger_pressed.emit()
	HeldKey = Keys.LEFT_TRIGGER
	StartHold()

func PressRightTrigger():
	right_trigger_pressed.emit()
	HeldKey = Keys.RIGHT_TRIGGER
	StartHold()

func PressDirection(direction: Vector2i):
	direction_pressed.emit(direction)
	
	if direction.y == -1:
		HeldKey = Keys.UP
	elif direction.y == 1:
		HeldKey = Keys.DOWN
	elif direction.x == -1:
		HeldKey = Keys.LEFT
	elif direction.x == 1:
		HeldKey = Keys.RIGHT
	
	StartHold()

func StartHold():
	if FirstHold == true:
		HoldTimer.start(FirstHoldTime)
		FirstHold = false
	else:
		HoldTimer.start(HoldTime)

func ResetHold():
	HeldKey = Keys.NULL
	HoldTimer.stop()
	FirstHold = true

func InputRelease():
	if Input.is_action_just_released("left_trigger"):
		if HeldKey == Keys.LEFT_TRIGGER:
			ResetHold()
			get_viewport().set_input_as_handled()
			return
	elif Input.is_action_just_released("right_trigger"):
		if HeldKey == Keys.RIGHT_TRIGGER:
			ResetHold()
			get_viewport().set_input_as_handled()
			return
	
	elif Input.is_action_just_released("move_up"):
		if HeldKey == Keys.UP:
			ResetHold()
			get_viewport().set_input_as_handled()
			return
	elif Input.is_action_just_released("move_down"):
		if HeldKey == Keys.DOWN:
			ResetHold()
			get_viewport().set_input_as_handled()
			return
	elif Input.is_action_just_released("move_left"):
		if HeldKey == Keys.LEFT:
			ResetHold()
			get_viewport().set_input_as_handled()
			return
	elif Input.is_action_just_released("move_right"):
		if HeldKey == Keys.RIGHT:
			ResetHold()
			get_viewport().set_input_as_handled()
			return
	
	else:
		return


##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_hold_timer_timeout() -> void:
	if HeldKey == Keys.NULL:
		return
	
	elif HeldKey == Keys.LEFT_TRIGGER:
		PressLeftTrigger()
		return
	elif HeldKey == Keys.RIGHT_TRIGGER:
		PressRightTrigger()
		return
	
	var direction : Vector2i = Vector2i(0,0)
	if HeldKey == Keys.UP:
		direction.y = -1
	elif HeldKey == Keys.DOWN:
		direction.y = 1
	elif HeldKey == Keys.LEFT:
		direction.x = -1
	elif HeldKey == Keys.RIGHT:
		direction.x = 1
	if direction != Vector2i(0,0):
		PressDirection(direction)
		return


##############################################################
#                      4.0 Godot Functions                   #
##############################################################
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	
	if event.is_released():
		InputRelease()
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
		PressLeftTrigger()
		get_viewport().set_input_as_handled()
		return
	
	if Input.is_action_just_pressed("right_trigger"):
		PressRightTrigger()
		get_viewport().set_input_as_handled()
		return
	
	var direction : Vector2i = Vector2i(0,0)
	if Input.is_action_just_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_just_pressed("move_down"):
		direction.y = 1
	elif Input.is_action_just_pressed("move_left"):
		direction.x = -1
	elif Input.is_action_just_pressed("move_right"):
		direction.x = 1
	if direction != Vector2i(0,0):
		PressDirection(direction)
		get_viewport().set_input_as_handled()
		return
