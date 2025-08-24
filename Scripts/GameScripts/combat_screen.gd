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
@export var PlayerPlaceholder: Unit
@export var EnemyPlaceholder: Unit
######################
#     SCRIPT-WIDE    #
######################
var Attacker: Unit
var Defender: Unit
var AttackerDuplicate: Unit
var DefenderDuplicate: Unit

var Damage: int
##############################################################
#                      2.0 Functions                         #
##############################################################

func StartCombat(attacker: Unit, defender: Unit, damage: int):
	Attacker = attacker
	Defender = defender
	Damage = damage
	
	AttackerDuplicate = Attacker.duplicate()
	DefenderDuplicate = Defender.duplicate()
	
	AttackerDuplicate.animation_hit.connect(_on_attacker_hit)
	
	add_child(AttackerDuplicate)
	AttackerDuplicate.CopyState(Attacker)
	AttackerDuplicate.UpdateHealth()
	
	add_child(DefenderDuplicate)
	DefenderDuplicate.CopyState(Defender)
	DefenderDuplicate.UpdateHealth()
	
	if Attacker.Faction == Unit.Factions.ENEMY:
		AttackerDuplicate.global_position = EnemyPlaceholder.global_position
		AttackerDuplicate.Sprite.flip_h = true
		DefenderDuplicate.global_position = PlayerPlaceholder.global_position
	else:
		AttackerDuplicate.global_position = PlayerPlaceholder.global_position
		DefenderDuplicate.global_position = EnemyPlaceholder.global_position
		DefenderDuplicate.Sprite.flip_h = true
	
	AttackerDuplicate.MyAnimationPlayer.play("attack")
	await AttackerDuplicate.MyAnimationPlayer.animation_finished
	
	combat_finished.emit()
	queue_free()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_attacker_hit():
	DefenderDuplicate.FlashDamageEffect()
	
	var max_hp = DefenderDuplicate.MaxHP
	var final_hp = DefenderDuplicate.CurrentHP - Damage
	DefenderDuplicate.HealthBar.update_health(final_hp, max_hp)

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
