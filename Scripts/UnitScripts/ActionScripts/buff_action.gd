class_name BuffAction
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
@export var Status: Unit.Status
@export var Duration: int
@export var Value: int

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	_execute(user, manager)

func _execute(user: Unit, manager: GameManager, _target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.SubState.PROCESSING_PHASE
	print(user.Data.Name + " is using a buff!")
	await user.PlayActionAnimation(AnimationName, user)
	
	user.AddStatus(Status, Duration, Value)
	StatusLogic.ApplyStatusLogic(user, Status)
	
	if user in manager.PlayerUnits:
		manager.EndPlayerTurn()
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
