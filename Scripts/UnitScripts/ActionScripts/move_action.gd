class_name MoveAction
extends Action
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

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.MOVE, -1)
	manager.MyCursor.show()

func _check_target(_user: Unit, _manager: GameManager = null, target = null) -> bool:
	if target is not Vector2i:
		return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	var path = manager.MyMoveManager.FindPath(user, user.CurrentTile, target)
	
	if path.path.is_empty():
		return null
	
	var tween = manager.create_tween()
	tween.set_parallel(false)
	
	for step in path.path:
		var step_global_position = manager.GroundGrid.to_global(manager.GroundGrid.map_to_local(step))
		tween.tween_property(user, "global_position", step_global_position, 0.2)
	
	user.CurrentTile = target
	user.HasMoved = true
	return tween

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
