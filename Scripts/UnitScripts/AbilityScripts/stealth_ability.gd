class_name StealthAbility
extends Ability
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

func connect_listeners(owner: Unit):
	owner.turn_started.connect(_on_owner_turn_started)

func apply_ability(owner: Unit):
	owner.AbilityStates[self] = false

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_owner_turn_started(owner: Unit):
	var is_active = owner.AbilityStates[self]
	if owner.HPPercent >= 1:
		if not is_active == true:
			owner.AggroModifier -= 1
			owner.AbilityStates[self] = true
	else:
		if not is_active == false:
			owner.AggroModifier += 1
			owner.AbilityStates[self] = false

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
