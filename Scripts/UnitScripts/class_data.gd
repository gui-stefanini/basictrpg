class_name ClassData
extends Resource

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################
######################
#     SCRIPT-WIDE    #
######################
#Ignoring default order for Inspector
@export var Name: String = "none"

#Stats
@export var ClassMaxHP: int = 0
@export var ClassGrowthMaxHP: float = 0.0
@export var ClassAttackPower: int = 0
@export var ClassGrowthAttackPower: float = 0.0
@export var ClassHealPower: int = 0
@export var ClassGrowthHealPower: float = 0.0

@export var ClassMoveRange: int = 0
@export var ClassAttackRange: int = 0
@export var ClassAggro: int = 0
@export var ClassSupportAggro: int = 0

#Info
@export var ClassAbilities: Array[Ability]
@export var ClassActions: Array[Action]
@export var ClassMovementType: MovementData

#Animation
@export var ClassSpriteSheet: Texture2D
@export var Hframes: int = 1
@export var Vframes: int = 1
@export var MyAnimationLibrary: AnimationLibrary

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
