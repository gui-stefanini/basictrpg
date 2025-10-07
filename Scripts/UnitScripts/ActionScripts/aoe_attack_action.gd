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

@export var AnimationName : String
@export var DamageModifier: int
@export var RangeModifier: int
@export var AOERange: int

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.CurrentAction = self
	manager.CurrentSubState = manager.SubState.TARGETING_PHASE
	var action_range = user.AttackRange + RangeModifier
	manager.MyActionManager.HighlightAOEArea(user, action_range)
	manager.MyActionManager.AOERange = AOERange
	manager.MyCursor.show()

func _check_target(_user: Unit, manager: GameManager = null, target = null) -> bool:
	if target is not Vector2i:
		return false
	
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	var targets : Array[Unit] = manager.MyActionManager.GetTargetsInArea(area, manager.AllUnits)
	
	if targets.is_empty():
		return false
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	print(user.Data.Name + " casts AOE spell!")
	
	var damage = user.AttackPower + DamageModifier
	
	var target_global_pos = manager.GroundGrid.to_global(manager.GroundGrid.map_to_local(target))
	await user.PlayActionAnimation(AnimationName, target_global_pos)
	
	var area : Array[Vector2i] = manager.MyActionManager.GetTilesInRange(target, AOERange, true)
	var targets : Array[Unit] = manager.MyActionManager.GetTargetsInArea(area, manager.AllUnits)
	
	for unit in targets:
		unit.TakeDamage(damage)
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
