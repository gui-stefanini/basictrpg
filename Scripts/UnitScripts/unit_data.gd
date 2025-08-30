class_name UnitData
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
@export var BaseMaxHP: int = 1
@export var BaseAttackPower: int = 1
@export var BaseHealPower: int = 0
@export var BaseMoveRange: int = 1
@export var BaseAttackRange: int = 1
@export var BaseAggro: int = 0
@export var BaseSupportAggro: int = 0

#Info
@export var Abilities: Array[Ability]
@export var Actions: Array[Action]
@export var MovementType: MovementData

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
