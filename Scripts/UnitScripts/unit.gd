class_name Unit
extends CharacterBody2D
##############################################################
#                      0.0 Signals                           #
##############################################################
signal damage_taken(unit: Unit, damage_data: Dictionary)
signal unit_died(unit: Unit)

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var Data: UnitData
@export var AI: AIBehavior
@export var Sprite: AnimatedSprite2D
@export var HealthBar: Control

######################
#     SCRIPT-WIDE    #
######################
enum Factions {PLAYER, ENEMY}
@export var Faction: Factions
enum Status {PASS, DEFENDING, POISONED, HASTED}
enum StatusInfo {DURATION, VALUE}
var CurrentHP: int = 1
var HPPercent: float = 1
var HasMoved: bool = false
var HasActed: bool = false
var IsDead: bool = false
var ActiveStatuses: Dictionary = {}

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      2.1 DAMAGE INTERACTION                #
##############################################################

func FlashDamageEffect():
	var original_color = Sprite.modulate
	var flash_color = Color.DARK_RED
	var blended_damage_color = original_color.lerp(flash_color, 0.7)
	var tween = create_tween()
	tween.tween_property(Sprite, "modulate", blended_damage_color, 0.2)
	tween.tween_property(Sprite, "modulate", original_color, 0.2)

func UpdateHealth():
	HPPercent = float(CurrentHP)/Data.MaxHP
	HealthBar.update_health(CurrentHP, Data.MaxHP)

func TakeDamage(damage_amount: int):
	var damage_data = {"damage": damage_amount}
	
	damage_taken.emit(self, damage_data)
	
	var final_damage = damage_data["damage"]
	CurrentHP -= final_damage
	CurrentHP = max(0, CurrentHP)
	
	FlashDamageEffect()
	
	print(name + " takes " + str(final_damage) + " damage! " + str(CurrentHP) + " HP remaining.")
	UpdateHealth()
	
	if CurrentHP <= 0:
		IsDead = true
		unit_died.emit(self)

func ReceiveHealing(heal_amount: int):
	CurrentHP += heal_amount
	CurrentHP = min(CurrentHP, Data.MaxHP)
	
	print(name + " is healed for " + str(heal_amount) + " HP! Now at " + str(CurrentHP) + " HP.")
	
	UpdateHealth()

##############################################################
#                      2.2 STATUS INTERACTION                #
##############################################################

func AddStatus(status: Status, duration: int, value: int = 0):
	if ActiveStatuses.has(status):
		var status_data = ActiveStatuses[status]
		if status_data[StatusInfo.DURATION] < duration:
			ActiveStatuses[status][StatusInfo.DURATION] = duration
		if status_data[StatusInfo.VALUE] < value:
			ActiveStatuses[status][StatusInfo.VALUE] = value
	else:
		var new_status = {StatusInfo.DURATION: duration, StatusInfo.VALUE: value}
		ActiveStatuses[status] = new_status
		StatusLogic.ApplyStatusLogic(self, status)
		print("%s gained status: %s for %d turns" % [name, Status.find_key(status), duration])

func StackStatus(status: Status, information: StatusInfo, amount: int):
	
	if ActiveStatuses.has(status):
		ActiveStatuses[status][information] += amount
	else:
		var new_status = {
			StatusInfo.DURATION: -1,
			StatusInfo.VALUE: -1
		}
		new_status[information] = amount
		ActiveStatuses[status] = new_status
		StatusLogic.ApplyStatusLogic(self, status)

##############################################################
#                      2.3 SET STATE                         #
##############################################################

func CopyState(target : Unit):
	CurrentHP = target.CurrentHP
	ActiveStatuses = target.ActiveStatuses.duplicate(true)

func StartTurn():
	HasMoved = false
	HasActed = false
	
	var statuses_to_remove = []
	for status in ActiveStatuses:
		var duration = ActiveStatuses[status][StatusInfo.DURATION]
		if duration > 0:
			duration -= 1
		if duration == 0:
			statuses_to_remove.append(status)
	
	for status in statuses_to_remove:
		StatusLogic.RemoveStatusLogic(self, status)
		ActiveStatuses.erase(status)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	if Data:
		CurrentHP = Data.MaxHP
		for action in Data.Actions:
			action.connect_listeners(self)
	UpdateHealth()
