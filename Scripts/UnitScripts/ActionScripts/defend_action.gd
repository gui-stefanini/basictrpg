class_name DefendAction
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

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	_execute(user, manager)

func _execute(user: Unit, manager: GameManager, _target = null, _simulation : bool = false) -> Variant:
	manager.CurrentSubState = manager.PlayerTurnState.PROCESSING_PHASE
	print(user.name + " is defending!")
	await user.PlayActionAnimation("defend", user)
	
	user.AddStatus(Unit.Status.DEFENDING, 1)
	StatusLogic.ApplyStatusLogic(user, Unit.Status.DEFENDING)
	
	if user in manager.PlayerUnits:
		manager.EndPlayerTurn()
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
