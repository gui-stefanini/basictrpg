class_name HealAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit, manager: GameManager):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.PlayerTurnState.TARGETING_PHASE
	manager.HighlightHealArea(user, user.Data.AttackRange)

func _execute(user: Unit, _manager: GameManager, target = null) -> Variant:
	if target is not Unit:
		print(str(self) + "has an invalid target type")
		return null
	
	target.ReceiveHealing(user.Data.HealPower)
	user.HasActed = true
	return null
