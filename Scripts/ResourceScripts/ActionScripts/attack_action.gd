class_name AttackAction
extends Action

func connect_listeners(_owner):
	pass

func _on_select(user, manager: Node2D):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.PlayerTurnState.TARGETING_PHASE
	manager.HighlightAttackArea(user, user.Data.AttackRange)

func _execute(user, manager: Node2D, target = null) -> Variant:
	#if target is not Unit:
		#print(str(self) + "has an invalid target type")
		#return
	
	print(user.name + " attacks " + target.name + "!")
	
	var damage = user.Data.AttackPower
	
	var was_defeated = target.TakeDamage(damage)
	
	if was_defeated:
		print(target.name + " has been defeated!")
		if target in manager.EnemyUnits:
			manager.EnemyUnits.erase(target)
			target.queue_free()
			if manager.EnemyUnits.is_empty():
				manager.EndGame(true)
		if target in manager.PlayerUnits:
			manager.PlayerUnits.erase(target)
			target.queue_free()
			if manager.PlayerUnits.is_empty():
				manager.EndGame(false)
	
	user.HasActed = true
	return null
