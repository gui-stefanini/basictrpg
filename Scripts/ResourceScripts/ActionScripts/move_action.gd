class_name MoveAction
extends Action

func connect_listeners(_owner):
	pass

func _on_select(user, manager: Node2D):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.PlayerTurnState.TARGETING_PHASE
	manager.HighlightMoveArea(user)

func _execute(user, manager: Node2D, target = null) -> Variant:
	if target is not Vector2i:
		print(str(self) + "has an invalid target type")
		return null
	
	var start_tile = manager.GroundGrid.local_to_map(user.global_position)
	var path = manager.FindPath(user, start_tile, target)
	
	if path.is_empty():
		return null
	
	var tween = manager.create_tween()
	tween.set_parallel(false)
	
	for step in path:
		var step_global_position = manager.GroundGrid.to_global(manager.GroundGrid.map_to_local(step))
		tween.tween_property(user, "global_position", step_global_position, 0.2)
	
	match manager.CurrentGameState:
		manager.GameState.PLAYER_TURN:
			manager.CurrentSubState = manager.PlayerTurnState.PROCESSING_PHASE
			tween.tween_callback(manager.OnPlayerActionFinished)
		
		manager.GameState.ENEMY_TURN:
			manager.CurrentSubState = manager.EnemyTurnState.PROCESSING_PHASE
	
	user.HasMoved = true
	return tween
