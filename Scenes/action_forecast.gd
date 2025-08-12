extends PanelContainer

@export var UnitNameLabel = Label
@export var TargetNameLabel = Label
@export var DamageLabel = Label
@export var TargetHPLabel = Label

func UpdateForecast(attacker: Unit, defender: Unit, damage: int):
	var final_hp = defender.CurrentHP - damage
	
	UnitNameLabel.text = attacker.name
	TargetNameLabel.text = "Target: " + defender.name
	DamageLabel.text = "Damage: " + str(damage)
	TargetHPLabel.text = "HP: " + str(defender.CurrentHP) + " -> " + str(final_hp)
