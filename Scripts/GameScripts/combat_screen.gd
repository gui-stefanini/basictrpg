class_name CombatScreen
extends CanvasLayer

##############################################################
#                      0.0 Signals                           #
##############################################################
signal combat_finished
@warning_ignore("unused_signal")
signal hit
##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var PlayerPosition: Marker2D
@export var EnemyPosition: Marker2D
######################
#     SCRIPT-WIDE    #
######################
var Attacker: Unit
var Defender: Unit
var Damage: int

# Store original state to restore it later
var AttackerOriginalParent: Node
var AttackerOriginalPosition: Vector2
var DefenderOriginalParent: Node
var DefenderOriginalPosition: Vector2

##############################################################
#                      2.0 Functions                         #
##############################################################

func StartCombat(attacker: Unit, defender: Unit, damage: int):
	Attacker = attacker
	Defender = defender
	Damage = damage

	# --- Store Original State ---
	AttackerOriginalParent = Attacker.get_parent()
	AttackerOriginalPosition = Attacker.global_position
	DefenderOriginalParent = Defender.get_parent()
	DefenderOriginalPosition = Defender.global_position

	# --- Reparent Units to Combat Screen ---
	AttackerOriginalParent.remove_child(Attacker)
	add_child(Attacker)
	DefenderOriginalParent.remove_child(Defender)
	add_child(Defender)
	
	# --- Connect to Signals ---
	Attacker.animation_hit.connect(_on_attacker_hit)

	# --- Position and Configure Units for Combat ---
	if Attacker.Faction == Unit.Factions.PLAYER:
		Attacker.global_position = PlayerPosition.global_position
		Defender.global_position = EnemyPosition.global_position
		Defender.Sprite.flip_h = true
	else:
		Attacker.global_position = EnemyPosition.global_position
		Attacker.Sprite.flip_h = true
		Defender.global_position = PlayerPosition.global_position

	# --- Play Animation ---
	Attacker.MyAnimationPlayer.play("attack")
	await Attacker.MyAnimationPlayer.animation_finished
	
	# --- Restore everything and clean up ---
	ReturnUnits()
	combat_finished.emit()
	queue_free()

func ReturnUnits():
	# Disconnect signal to prevent multiple calls
	if Attacker.animation_hit.is_connected(_on_attacker_hit):
		Attacker.animation_hit.disconnect(_on_attacker_hit)
		
	# --- Reparent Units back to the Main Scene ---
	remove_child(Attacker)
	AttackerOriginalParent.add_child(Attacker)
	remove_child(Defender)
	DefenderOriginalParent.add_child(Defender)
	
	# --- Restore Original State ---
	Attacker.global_position = AttackerOriginalPosition
	Defender.global_position = DefenderOriginalPosition
	Attacker.Sprite.flip_h = false
	Defender.Sprite.flip_h = false

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_attacker_hit():
	Defender.FlashDamageEffect()
	
	var max_hp = Defender.MaxHP
	# We simulate the health change for the UI, but the actual damage
	# will be applied in the AttackAction after the animation.
	var final_hp = Defender.CurrentHP - Damage
	Defender.HealthBar.update_health(final_hp, max_hp)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
