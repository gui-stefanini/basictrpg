class_name AttackAction
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

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	var action_range = user.AttackRange + RangeModifier
	manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.ATTACK, action_range)
	manager.MyCursor.show()

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	if target is not Unit:
		return false
	
	var hostile_array : Array[Unit] = UnitManager.GetHostileArray(user)
	if not hostile_array.has(target):
		return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, simulation : bool = false) -> Variant:
	print(user.Data.Name + " attacks " + target.Data.Name + "!")
	
	var damage = user.AttackPower + DamageModifier
	
	if simulation == false:
		var final_damage = await manager.MyActionManager.PreviewAction(self, user, target)
		await manager.MyActionManager.StartCombat(user, target, final_damage)
	
	print("Combat finished, apllying damage")
	target.TakeDamage(damage)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
