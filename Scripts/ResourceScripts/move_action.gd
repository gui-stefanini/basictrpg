class_name MoveAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit):
	var map = user.get_tree().current_scene
	map.CurrentAction = self
	map.CurrentSubState = map.PlayerTurnState.TARGETING_PHASE
	map.HighlightMoveArea(user)

func _execute(user: Unit, target = null):
	if target is not Vector2i:
		print(str(self) + "has an invalid target type")
	
	var map = user.get_tree().current_scene
	map.MoveUnit(target, user)
	user.HasMoved = true
