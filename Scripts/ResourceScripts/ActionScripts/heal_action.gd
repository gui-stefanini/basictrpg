class_name HealAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, map: Node2D):
	map.CurrentAction = self
	map.CurrentSubState = map.PlayerTurnState.TARGETING_PHASE
	map.HighlightHealArea(user, user.Data.AttackRange)

func _execute(user: Unit, _map: Node2D, target = null) -> Variant:
	if target is not Unit:
		print(str(self) + "has an invalid target type")
		return null
	
	target.ReceiveHealing(user.Data.HealPower)
	user.HasActed = true
	return null
