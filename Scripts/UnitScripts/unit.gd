class_name Unit
extends CharacterBody2D
##############################################################
#                      0.0 Signals                           #
##############################################################

signal turn_started(unit: Unit)

signal vfx_requested(vfx_data: VFXData, animation_name: String, vfx_position: Vector2, is_combat : bool)
signal animation_hit

signal damage_taken(unit: Unit, damage_data: Dictionary)
signal unit_died(unit: Unit)

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var Data: CharacterData
@export var MyAI: AI
@export var RotationTracker: Node2D
@export var Sprite: Sprite2D
@export var MyAnimationPlayer: AnimationPlayer
@export var HealthBar: Control

######################
#     SCRIPT-WIDE    #
######################

enum Factions {PLAYER, ENEMY}
@export var Faction: Factions

enum Status {PASS, DEFENDING, REGENERATING, POISONED}
enum StatusInfo {DURATION, VALUE}
var HasMoved: bool = false
var HasActed: bool = false
var IsDead: bool = false
var ActiveStatuses: Dictionary = {}
var AbilityStates: Dictionary = {}

var ActionTarget
var CurrentTile: Vector2i

######################
#       STATS        #
######################

var MaxHPModifier: int = 0
var MaxHP: int:
	get: return Data.BaseMaxHP + MaxHPModifier

var CurrentHP: int = 1

var HPPercent: float:
	get: return float(CurrentHP)/MaxHP

var AttackPowerModifier: int = 0
var AttackPower: int:
	get: return Data.BaseAttackPower + AttackPowerModifier

var HealPowerModifier: int = 0
var HealPower: int:
	get: return Data.BaseHealPower + HealPowerModifier

var MoveRangeModifier: int = 0
var MoveRange: int:
	get: return Data.BaseMoveRange + MoveRangeModifier

var AttackRangeModifier: int = 0
var AttackRange: int:
	get: return Data.BaseAttackRange + AttackRangeModifier

var AggroModifier: int = 0
var Aggro: int:
	get: return Data.BaseAggro + AggroModifier

var SupportAggroModifier: int = 0
var SupportAggro: int:
	get: return Data.BaseSupportAggro + SupportAggroModifier

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      2.1 DAMAGE INTERACTION                #
##############################################################

func UpdateHealth():
	HealthBar.update_health(CurrentHP, MaxHP)

func TakeDamage(damage_amount: int, percentage: bool = false, 
				true_damage: bool = false, lethal: bool = true):
	if percentage == true:
		damage_amount = roundi(MaxHP * damage_amount/100.0)
	
	var damage_data = {"damage": damage_amount}
	
	if true_damage == false:
		damage_taken.emit(self, damage_data)
	
	var final_damage = roundi(damage_data["damage"])
	CurrentHP -= final_damage
	if lethal == true:
		CurrentHP = max(0, CurrentHP)
	else:
		CurrentHP = max(1, CurrentHP)
	
	print(Data.Name + " takes " + str(final_damage) + " damage! " + str(CurrentHP) + " HP remaining.")
	UpdateHealth()
	
	if CurrentHP <= 0:
		IsDead = true
		unit_died.emit(self)

func ReceiveHealing(heal_amount: int, percentage: bool = false):
	if percentage == true:
		heal_amount = roundi(MaxHP * heal_amount/100.0)
	CurrentHP += heal_amount
	CurrentHP = min(CurrentHP, MaxHP)
	
	print(Data.Name + " is healed for " + str(heal_amount) + " HP! Now at " + str(CurrentHP) + " HP.")
	
	UpdateHealth()

##############################################################
#                      2.2 STATUS INTERACTION                #
##############################################################

func AddStatus(status: Status, duration: int = -1, value: int = -1, 
			   stack_duration: bool = false, stack_value: bool = false):
	
	if ActiveStatuses.has(status):
		var status_data = ActiveStatuses[status]
		
		if stack_duration == false:
			ActiveStatuses[status][StatusInfo.DURATION] = max(status_data[StatusInfo.DURATION], duration)
		else:
			ActiveStatuses[status][StatusInfo.DURATION] += duration
		
		if stack_value == false:
			ActiveStatuses[status][StatusInfo.VALUE] = max(status_data[StatusInfo.VALUE], value)
		else:
			ActiveStatuses[status][StatusInfo.VALUE] += value
	
	else:
		var new_status = {StatusInfo.DURATION: duration, StatusInfo.VALUE: value}
		ActiveStatuses[status] = new_status
		StatusLogic.ApplyStatusLogic(self, status)
		print("%s gained status: %s for %d turns" % [Data.Name, Status.find_key(status), duration])

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

func SetInactive():
	Sprite.material.set_shader_parameter("grayscale_modifier", 0.6)

func SetActive():
	Sprite.material.set_shader_parameter("grayscale_modifier", 0.0)

func SetSprite():
	Sprite.texture = Data.SpriteSheet
	Sprite.hframes = Data.Hframes
	Sprite.vframes = Data.Vframes
	Sprite.frame = 0
	Sprite.material = Sprite.material.duplicate()
	
	if Data.MyAnimationLibrary and not MyAnimationPlayer.has_animation_library("character_library"):
		MyAnimationPlayer.add_animation_library("character_library", Data.MyAnimationLibrary)
	
	match Faction:
		Factions.PLAYER:
			Sprite.material.set_shader_parameter("new_color", ColorList.PlayerFactionColor)
		Factions.ENEMY:
			if Data.Boss == true:
				Sprite.material.set_shader_parameter("new_color", ColorList.BossColor)
			else:
				Sprite.material.set_shader_parameter("new_color", ColorList.EnemyFactionColor)

func SetSkills():
	for ability in Data.Abilities:
		ability.connect_listeners(self)
		ability.apply_ability(self)
	
	for action in Data.Actions:
		action.connect_listeners(self)

func SetData(spawn_level: int = -1):
	#When no Generic, it IS supposed to be able to edit the character data itself
	if Data.Generic == true:
		Data = Data.duplicate()
		Data.CharacterLevel = spawn_level
	Data.ClassOverride()
	
	SetSkills()
	SetSprite()

func CopyState(target : Unit):
	Data = target.Data.duplicate()
	Data.CharacterLevel = target.Data.CharacterLevel
	Data.SetStats()
	
	CurrentHP = target.CurrentHP
	AggroModifier = target.AggroModifier
	ActiveStatuses = target.ActiveStatuses.duplicate(true)
	
	for status in ActiveStatuses:
		StatusLogic.ApplyStatusLogic(self, status)
	
	for ability in Data.Abilities:
		ability.connect_listeners(self)
		ability.apply_ability(self)
	
	AbilityStates = target.AbilityStates.duplicate(true)

func StartTurn():
	turn_started.emit(self)
	HasMoved = false
	HasActed = false
	SetActive()
	
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
#                      2.3 ANIMATIONS                        #
##############################################################

func StopAnimation():
	MyAnimationPlayer.stop()
	Sprite.frame = 0

func PlayIdleAnimation():
	MyAnimationPlayer.play("character_library/idle")

func PlayActionAnimation(animation_name: String, target):
	if target is not Unit and target is not Vector2:
		return
	ActionTarget = target
	MyAnimationPlayer.play("character_library/" + animation_name)
	await MyAnimationPlayer.animation_finished
	ActionTarget = null

func RequestVFX(vfx_data: VFXData, animation_name: String, is_combat: bool = false):	
	var vfx_position : Vector2 = self.global_position
	if ActionTarget is Vector2:
		vfx_position = ActionTarget
	if ActionTarget is Unit:
		vfx_position = ActionTarget.global_position
	vfx_requested.emit(vfx_data, animation_name, vfx_position, is_combat)

##############################################################
#                      3.0 Signal Functions                  #
##############################################################
#Linked manually on SetAnimations()
func _on_animation_hit():
	animation_hit.emit()

func _on_animation_being_hit():
	MyAnimationPlayer.play("character_library/hit")
##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _ready():
	#SetData()
	CurrentHP = MaxHP
	UpdateHealth()
