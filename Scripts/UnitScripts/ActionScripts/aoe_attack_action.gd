class_name AOEAttackAction
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
@export var AOERange: int

##############################################################
#                      2.0 Functions                         #
##############################################################

func GetActionRange(user: Unit) -> int:
	return user.AttackRange + RangeModifier

func GetTargets(manager: GameManager, target: Vector2i) -> Array[Unit]:
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	return manager.MyActionManager.GetTargetsInArea(area, UnitManager.AllUnits)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	SelectAOE(user, manager, ActionManager.HighlightTypes.AOE, AOERange)

func _check_target(_user: Unit, manager: GameManager = null, target = null) -> bool:
	if target is not Vector2i:
		return false
	
	var targets: Array[Unit] = GetTargets(manager, target)
	
	if targets.is_empty():
		return false
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	print(user.Data.Name + " casts AOE spell!")
	
	var damage = user.AttackPower + DamageModifier
	var target_global_pos = manager.GroundGrid.to_global(manager.GroundGrid.map_to_local(target))
	await user.PlayActionAnimation(AnimationName, target_global_pos)
	
	var targets: Array[Unit] = GetTargets(manager, target)
	
	for unit in targets:
		unit.TakeDamage(damage)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
