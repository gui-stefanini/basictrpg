class_name MoveAction
extends Action

func _execute(user: Unit, target = null):
	var map = user.get_tree().current_scene
	map.CurrentSubState = map.PlayerTurnState.MOVEMENT_PHASE
	map.HighlightMoveArea(user)
