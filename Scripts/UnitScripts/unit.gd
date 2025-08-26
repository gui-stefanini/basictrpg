class_name Unit
extends CharacterBody2D
##############################################################
#                      0.0 Signals                           #
##############################################################

signal turn_started(unit: Unit)

signal animation_hit

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
@export var RotationTracker: Node2D
@export var Sprite: Sprite2D
@export var MyAnimationPlayer: AnimationPlayer
@export var HealthBar: Control
@export var PlayerFactionColor: Color = Color("4169E1") # Royal Blue
@export var EnemyFactionColor: Color = Color("DC143C") # Crimson
######################
#     SCRIPT-WIDE    #
######################
enum Factions {PLAYER, ENEMY}
@export var Faction: Factions
enum Status {PASS, DEFENDING, POISONED, HASTED}
enum StatusInfo {DURATION, VALUE}
var HasMoved: bool = false
var HasActed: bool = false
var IsDead: bool = false
var ActiveStatuses: Dictionary = {}
var AbilityStates: Dictionary = {}
######################
#       STATS        #
######################
var MaxHP: int:
	get: return Data.BaseMaxHP + MaxHPModifier
var MaxHPModifier: int = 0

var CurrentHP: int = 1
var HPPercent: float:
	get: return float(CurrentHP)/Data.BaseMaxHP

var AttackPower: int:
	get: return Data.BaseAttackPower + AttackPowerModifier
var AttackPowerModifier: int = 0

var HealPower: int:
	get: return Data.BaseHealPower + HealPowerModifier
var HealPowerModifier: int = 0

var MoveRange: int:
	get: return Data.BaseMoveRange + MoveRangeModifier
var MoveRangeModifier: int = 0

var AttackRange: int:
	get: return Data.BaseAttackRange + AttackRangeModifier
var AttackRangeModifier: int = 0

var Aggro: int:
	get: return Data.BaseAggro + AggroModifier
var AggroModifier: int = 0

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      2.1 DAMAGE INTERACTION                #
##############################################################

func UpdateHealth():
	HealthBar.update_health(CurrentHP, MaxHP)

func TakeDamage(damage_amount: int):
	var damage_data = {"damage": damage_amount}
	
	damage_taken.emit(self, damage_data)
	
	var final_damage = damage_data["damage"]
	CurrentHP -= final_damage
	CurrentHP = max(0, CurrentHP)
	
	
	print(name + " takes " + str(final_damage) + " damage! " + str(CurrentHP) + " HP remaining.")
	UpdateHealth()
	
	if CurrentHP <= 0:
		IsDead = true
		unit_died.emit(self)

func ReceiveHealing(heal_amount: int):
	CurrentHP += heal_amount
	CurrentHP = min(CurrentHP, MaxHP)
	
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

func SetData():
	Data = Data.duplicate()
	
	Sprite.texture = Data.ClassSpriteSheet
	Sprite.hframes = Data.Hframes
	Sprite.vframes = Data.Vframes
	Sprite.frame = 0
	Sprite.material = Sprite.material.duplicate()
	
	if Data.MyAnimationLibrary and not MyAnimationPlayer.has_animation_library("class_library"):
		# Replace the existing animation library with the one from our UnitData.
		MyAnimationPlayer.add_animation_library("class_library", Data.MyAnimationLibrary)
	
	match Faction:
		Factions.PLAYER:
			Sprite.material.set_shader_parameter("new_color", PlayerFactionColor)
		Factions.ENEMY:
			Sprite.material.set_shader_parameter("new_color", EnemyFactionColor)
	
	for ability in Data.Abilities:
		ability.connect_listeners(self)
		ability.apply_ability(self)
	
	for action in Data.Actions:
		action.connect_listeners(self)

func CopyState(target : Unit):
	Data = target.Data.duplicate()
	CurrentHP = target.CurrentHP
	AggroModifier = target.AggroModifier
	ActiveStatuses = target.ActiveStatuses.duplicate(true)
	AbilityStates = target.AbilityStates.duplicate(true)

func StartTurn():
	turn_started.emit(self)
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

#Linked manually on SetAnimations()
func _on_animation_hit():
	animation_hit.emit()

func _on_animation_being_hit():
	MyAnimationPlayer.play("class_library/hit")
##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	SetData()
	CurrentHP = MaxHP
	UpdateHealth()
