class_name HealAction
extends Action

func connect_listeners(_owner: Unit):
	pass

func _on_select(user: Unit):
	var map = user.get_tree().current_scene
	map.CurrentAction = self
	map.CurrentSubState = map.PlayerTurnState.TARGETING_PHASE
	map.HighlightHealArea(user, user.Data.AttackRange)

func _execute(user: Unit, target = null):
	if target is not Unit:
		print(str(self) + "has an invalid target type")
	else:
		target.ReceiveHealing(user.Data.HealPower)
		user.HasActed = true
