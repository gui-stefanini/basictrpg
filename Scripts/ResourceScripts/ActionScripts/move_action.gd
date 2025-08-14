class_name MoveAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, map: Node2D):
	map.CurrentAction = self
	map.CurrentSubState = map.PlayerTurnState.TARGETING_PHASE
	map.HighlightMoveArea(user)

func _execute(user: Unit, map: Node2D, target = null):
	if target is not Vector2i:
		print(str(self) + "has an invalid target type")
		return
	
	map.MoveUnit(user, target)
	user.HasMoved = true
