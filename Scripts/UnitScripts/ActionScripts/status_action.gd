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
	if SelfTarget == SelfTargetRule.ONLY:
		_execute(user, manager, user)
		return
	
	manager.CurrentAction = self
	manager.CurrentSubState = manager.SubState.TARGETING_PHASE
	var action_range = user.AttackRange + RangeModifier
	
	if Debuff == true:
		manager.MyActionManager.HighlightAttackArea(user, action_range)
	else:
		var include_self : bool = false
		if SelfTarget == SelfTargetRule.INCLUDE:
			include_self = true
		manager.MyActionManager.HighlightHealArea(user, action_range, include_self)
	
	manager.MyCursor.show()

func _check_target(user: Unit, _manager: GameManager = null, target = null) -> bool:
	if target is not Unit:
		return false
	
	var user_friendly: bool = user.Faction in [Unit.Factions.PLAYER, Unit.Factions.ALLY]
	var target_friendly: bool = target.Faction in [Unit.Factions.PLAYER, Unit.Factions.ALLY]
	var opponents: bool = user_friendly != target_friendly
	
	if Debuff == true:
		if opponents == false:
			return false
	else:
		if opponents == true:
			return false
	
	return true

func _execute(user: Unit, manager: GameManager, target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	print(user.Data.Name + " is using a status action!")
	if SelfTarget == SelfTargetRule.ONLY:
		target = user
	
	await user.PlayActionAnimation(AnimationName, target)
	
	target.AddStatus(Status, Duration, Value, StackDuration, StackValue)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
