class_name MoveAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, map: Node2D):
	map.CurrentAction = self
	map.CurrentSubState = map.PlayerTurnState.TARGETING_PHASE
	map.HighlightMoveArea(user)

func _execute(user: Unit, map: Node2D, target = null) -> Variant:
	if target is not Vector2i:
		print(str(self) + "has an invalid target type")
		return null
	
	var start_tile = map.GroundGrid.local_to_map(user.global_position)
	var path = map.FindPath(user, start_tile, target)
	
	if path.is_empty():
		return null
	
	var tween = map.create_tween()
	tween.set_parallel(false)
	
	for step in path:
		var step_global_position = map.GroundGrid.to_global(map.GroundGrid.map_to_local(step))
		tween.tween_property(user, "global_position", step_global_position, 0.2)
	
	match map.CurrentGameState:
		map.GameState.PLAYER_TURN:
			map.CurrentSubState = map.PlayerTurnState.PROCESSING_PHASE
			tween.tween_callback(map.OnPlayerActionFinished)
		
		map.GameState.ENEMY_TURN:
			map.CurrentSubState = map.EnemyTurnState.PROCESSING_PHASE
	
	user.HasMoved = true
	return tween
