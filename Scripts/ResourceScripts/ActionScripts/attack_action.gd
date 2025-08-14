class_name AttackAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, map: Node2D):
	map.CurrentAction = self
	map.CurrentSubState = map.PlayerTurnState.TARGETING_PHASE
	map.HighlightAttackArea(user, user.Data.AttackRange)

func _execute(user: Unit, map: Node2D, target = null):
	if target is not Unit:
		print(str(self) + "has an invalid target type")
		return
	
	print(user.name + " attacks " + target.name + "!")
	
	var damage = user.Data.AttackPower
	
	var was_defeated = target.TakeDamage(damage)
	
	if was_defeated:
		print(target.name + " has been defeated!")
		if target in map.EnemyUnits:
			map.EnemyUnits.erase(target)
			target.queue_free()
			if map.EnemyUnits.is_empty():
				map.EndGame(true)
		if target in map.PlayerUnits:
			map.PlayerUnits.erase(target)
			target.queue_free()
			if map.PlayerUnits.is_empty():
				map.EndGame(false)
	
	user.HasActed = true
