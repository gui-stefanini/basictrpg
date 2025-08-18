extends Control

@export var NameLabel = Label
@export var HPLabel = Label
@export var AttackLabel = Label
@export var MoveLabel = Label
@export var AttackRangeLabel = Label

func UpdatePanel(unit: Unit):
	if not unit:
		hide()
		return
	
	NameLabel.text = unit.name
	HPLabel.text = "HP: " + str(unit.CurrentHP) + " / " + str(unit.Data.MaxHP)
	AttackLabel.text = "ATK: " + str(unit.Data.AttackPower)
	MoveLabel.text = "MOV: " + str(unit.Data.MoveRange)
	AttackRangeLabel.text = "RNG: " + str(unit.Data.AttackRange)
	show()
