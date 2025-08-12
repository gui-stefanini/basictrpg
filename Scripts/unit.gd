class_name Unit
extends CharacterBody2D

signal damage_taken(damage_data: Dictionary)

@export var Data: UnitData
@export var Sprite: AnimatedSprite2D
@export var HealthBar: Control
enum Factions {PLAYER, ENEMY}
@export var Faction: Factions
enum Status {DEFENDING, POISONED, HASTED}
var CurrentHP: int = 1
var HasMoved: bool = false
var HasActed: bool = false
var ActiveStatuses: Dictionary = {}

func StartTurn():
	HasMoved = false
	HasActed = false
	
	var statuses_to_remove = []
	for status in ActiveStatuses:
		ActiveStatuses[status] -= 1
		if ActiveStatuses[status] <= 0:
			statuses_to_remove.append(status)
	
	for status in statuses_to_remove:
		ActiveStatuses.erase(status)

func FlashDamageEffect():
	var original_color = Sprite.modulate
	var flash_color = Color.DARK_RED
	var blended_damage_color = original_color.lerp(flash_color, 0.7)
	var tween = create_tween()
	tween.tween_property(Sprite, "modulate", blended_damage_color, 0.2)
	tween.tween_property(Sprite, "modulate", original_color, 0.2)

func TakeDamage(damage_amount: int) -> bool:
	var damage_data = {"damage": damage_amount}
	
	damage_taken.emit(damage_data)
	
	var final_damage = damage_data["damage"]
	CurrentHP -= final_damage
	CurrentHP = max(0, CurrentHP)
	
	FlashDamageEffect()
	
	print(name + " takes " + str(final_damage) + " damage! " + str(CurrentHP) + " HP remaining.")
	HealthBar.update_health(CurrentHP, Data.MaxHP)
	return CurrentHP <= 0

func _ready():
	if Data:
		CurrentHP = Data.MaxHP
	HealthBar.update_health(CurrentHP, Data.MaxHP)
