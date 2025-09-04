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
@export var TimeManager: Timer
######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func Wait(seconds: float):
	TimeManager.wait_time = seconds
	TimeManager.start()
	await TimeManager.timeout

func RandomizeInt(low: int, high: int, include : bool = true) -> int: 
	if include == true:
		return randi_range(low, high) 
	else:
		var new_low: int = low + 1
		var new_high: int = high - 1
		return randi_range(new_low, new_high)

func RandomizeFloat(low: float, high: float, include : bool = true) -> float: 
	if include == true:
		return randf_range(low, high) 
	else:
		var new_low: float = low + 0.01
		var new_high: float = high - 0.01
		return randf_range(new_low, new_high)

func ClampIndex(current_index: int, direction: int, size: int) -> int:
	var new_index = (current_index + direction + size) % size
	return new_index

func ClampIndexInArray(current_index: int, direction: int, array: Array) -> int:
	var array_size: int = array.size()
	return ClampIndex(current_index, direction, array_size)

func AddUniqueArrays(base_array: Array, added_array: Array):
	for element in added_array:
		if not base_array.has(element):
			base_array.append(element)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
func _ready() -> void:
	randomize()
