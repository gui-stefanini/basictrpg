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
	
	global_position = attacker.global_position + Vector2(10, -10)
	UiFunctions.ClampUI(self)
	show()

func _ready() -> void:
	UiFunctions.SetMouseIgnore(self)
