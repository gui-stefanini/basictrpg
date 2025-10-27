class_name RandomAttackAction
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

@export var DamageModifier: int
@export var RangeModifier: int

##############################################################
#                      2.0 Functions                         #
##############################################################

func GetActionRange(user: Unit) -> int:
	return user.AttackRange + RangeModifier

func GetTargets(user: Unit, manager: GameManager) -> Array[Unit]:
	var action_range = GetActionRange(user)
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(user.CurrentTile, action_range)
	
	var hostile_array : Array[Unit] = UnitManager.GetHostileArray(user)
	
	var targets : Array[Unit] = manager.MyActionManager.GetTargetsInArea(area, hostile_array)
	return targets

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	SelectSelf(user, manager, ActionManager.HighlightTypes.ATTACK)

func _check_target(user: Unit, manager: GameManager = null, target = null) -> bool:
	if target != null:
		return false
	
	var targets = GetTargets(user, manager)
	
	if targets.is_empty():
		return false
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	print(user.Data.Name + " casts Random Attack spell!")
	
	var damage = user.AttackPower + DamageModifier
	
	var targets = GetTargets(user, manager)
	target = targets.pick_random()
	
	await user.PlayActionAnimation(AnimationName, target)
	
	target.TakeDamage(damage)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
