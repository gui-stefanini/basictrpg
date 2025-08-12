class_name AttackAction
extends Action

func _execute(user: Unit, target = null):
	var map = user.get_tree().current_scene
	map.CurrentSubState = map.PlayerTurnState.ATTACK_PHASE
	map.HighlightAttackArea(user, user.Data.AttackRange)
