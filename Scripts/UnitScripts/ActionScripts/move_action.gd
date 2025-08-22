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

func connect_listeners(_owner: Unit):
	pass

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.PlayerTurnState.TARGETING_PHASE
	manager.MyActionManager.HighlightMoveArea(user)

func _execute(user: Unit, manager: GameManager, target = null) -> Variant:
	if target is not Vector2i:
		print(str(self) + "has an invalid target type")
		return null
	
	var start_tile = manager.GroundGrid.local_to_map(user.global_position)
	var path = manager.MyMoveManager.FindPath(user, start_tile, target)
	
	if path.path.is_empty():
		return null
	
	var tween = manager.create_tween()
	tween.set_parallel(false)
	
	for step in path.path:
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

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
