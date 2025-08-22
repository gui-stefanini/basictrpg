extends Control
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var NameLabel = Label
@export var HPLabel = Label
@export var AttackLabel = Label
@export var MoveLabel = Label
@export var AttackRangeLabel = Label
######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

func UpdatePanel(unit: Unit):
	if not unit:
		hide()
		return
	
	NameLabel.text = unit.name
	HPLabel.text = "HP: " + str(unit.CurrentHP) + " / " + str(unit.Data.MaxHP)
	AttackLabel.text = "ATK: " + str(unit.Data.AttackPower)
	MoveLabel.text = "MOV: " + str(unit.Data.MoveRange)
	AttackRangeLabel.text = "RNG: " + str(unit.Data.AttackRange)
	UiFunctions.ClampUI(self)
	show()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready() -> void:
	UiFunctions.SetMouseIgnore(self)
