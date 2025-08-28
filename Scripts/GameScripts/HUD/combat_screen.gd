class_name CombatScreen
extends CanvasLayer

##############################################################
#                      0.0 Signals                           #
##############################################################
signal combat_finished
@warning_ignore("unused_signal")
signal animation_hit
##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
@export var VfxScene: PackedScene
@export var Background: TextureRect
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
var AttackerOriginalFrame: int
var DefenderOriginalParent: Node
var DefenderOriginalPosition: Vector2
var DefenderOriginalFrame: int

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
	AttackerOriginalFrame = Attacker.Sprite.frame
	
	DefenderOriginalParent = Defender.get_parent()
	DefenderOriginalPosition = Defender.global_position
	DefenderOriginalFrame = Defender.Sprite.frame

	# --- Reparent Units to Combat Screen ---
	AttackerOriginalParent.remove_child(Attacker)
	add_child(Attacker)
	
	DefenderOriginalParent.remove_child(Defender)
	add_child(Defender)
	
	# --- Connect to Signals ---
	Attacker.animation_hit.connect(_on_attacker_hit)
	Attacker.vfx_requested.connect(_on_vfx_requested)
	animation_hit.connect(Defender._on_animation_being_hit)
	
	# --- Position and Configure Units for Combat ---
	if Attacker.Faction == Unit.Factions.PLAYER:
		Attacker.global_position = PlayerPosition.global_position
		
		Defender.global_position = EnemyPosition.global_position
		#Defender.Sprite.flip_h = true
		Defender.RotationTracker.scale.x = -1
	else:
		Attacker.global_position = EnemyPosition.global_position
		Attacker.RotationTracker.scale.x = -1
		
		Defender.global_position = PlayerPosition.global_position

	# --- Play Animation ---
	Attacker.MyAnimationPlayer.play("class_library/attack")
	await Attacker.MyAnimationPlayer.animation_finished
	
	# --- Restore everything and clean up ---
	ReturnUnits()
	combat_finished.emit()
	queue_free()

func ReturnUnits():
	# Disconnect signal to prevent multiple calls
	if Attacker.animation_hit.is_connected(_on_attacker_hit):
		Attacker.animation_hit.disconnect(_on_attacker_hit)
	if Attacker.vfx_requested.is_connected(_on_vfx_requested):
		Attacker.vfx_requested.disconnect(_on_vfx_requested)
	
	# --- Reparent Units back to the Main Scene ---
	remove_child(Attacker)
	AttackerOriginalParent.add_child(Attacker)
	remove_child(Defender)
	DefenderOriginalParent.add_child(Defender)
	
	# --- Restore Original State ---
	Attacker.global_position = AttackerOriginalPosition
	Attacker.Sprite.frame = AttackerOriginalFrame
	Attacker.RotationTracker.scale.x = 1 # Reset RotationTracker scale
	#Attacker.Sprite.flip_h = false
	
	Defender.global_position = DefenderOriginalPosition
	Defender.Sprite.frame = DefenderOriginalFrame
	Defender.RotationTracker.scale.x = 1 # Reset RotationTracker scale
	#Defender.Sprite.flip_h = false
##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_attacker_hit():
	var tween = create_tween()
	Background.modulate = Color(3, 2, 2, 1)
	tween.tween_property(Background, "modulate", Color(1, 1, 1, 1), 0.2)
	
	animation_hit.emit()
	
	var max_hp = Defender.MaxHP
	# We simulate the health change for the UI, but the actual damage
	# will be applied in the AttackAction after the animation.
	var final_hp = Defender.CurrentHP - Damage
	Defender.HealthBar.update_health(final_hp, max_hp)

func _on_vfx_requested(vfxdata: VFXData, animation_name: String, _vfx_position: Vector2, is_combat: bool):
	if is_combat == false:
		return
	if not vfxdata: 
		push_warning("Failed to load VFX Data")
		return
	
	var vfx : VFX = VfxScene.instantiate()
	add_child(vfx)
	
	vfx.SetData(vfxdata)
	vfx.global_position = Attacker.global_position
	
	if Attacker.Faction == Unit.Factions.ENEMY:
		vfx.MyRotationTracker.scale.x = -1
	
	vfx.MyAnimationPlayer.play("vfx/" + animation_name)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
