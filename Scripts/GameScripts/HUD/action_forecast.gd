extends PanelContainer
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var UnitNameLabel = Label
@export var TargetNameLabel = Label
@export var DamageLabel = Label
@export var TargetHPLabel = Label

######################
#     SCRIPT-WIDE    #
######################
##############################################################
#                      2.0 Functions                         #
##############################################################

func UpdateForecast(attacker: Unit, defender: Unit, damage: int):
	var final_hp = defender.CurrentHP - damage
	
	UnitNameLabel.text = attacker.name
	TargetNameLabel.text = "Target: " + defender.name
	DamageLabel.text = "Damage: " + str(damage)
	TargetHPLabel.text = "HP: " + str(defender.CurrentHP) + " -> " + str(final_hp)
	
	global_position = attacker.global_position + Vector2(10, -10)
	UiFunctions.call_deferred("ClampUI", self)
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
