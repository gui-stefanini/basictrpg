class_name StatusAction
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

@export var SelfTarget: bool
@export var Debuff: bool
@export var RangeModifier: int

@export var Status: Unit.Status
@export var StackDuration: bool
@export var Duration: int
@export var StackValue: bool
@export var Value: int


##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	if SelfTarget == true:
		_execute(user, manager, user)
	
	else:
		manager.CurrentAction = self
		manager.CurrentSubState = manager.SubState.TARGETING_PHASE
		var action_range = user.AttackRange + RangeModifier
		if Debuff == true:
			manager.MyActionManager.HighlightAttackArea(user, action_range)
		else:
			manager.MyActionManager.HighlightHealArea(user, action_range)
		manager.MyCursor.show()

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	if target is not Unit:
		return false
	if Debuff == true:
		if target.Faction == user.Faction:
			return false
	else:
		if target.Faction != user.Faction:
			return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	print(user.Data.Name + " is using a status action!")
	if SelfTarget == true:
		target = user
	
	await user.PlayActionAnimation(AnimationName, target)
	
	target.AddStatus(Status, Duration, Value, StackDuration, StackValue)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
