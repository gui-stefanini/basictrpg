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
@export var MaxHP: int = 1
@export var AttackPower: int = 1
@export var HealPower: int = 0
@export var MoveRange: int = 1
@export var AttackRange: int = 1
@export var Aggro: int = 0
@export var Actions: Array[Action]
@export var MovementType: MovementData
@export var ClassSpriteFrames: SpriteFrames
##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
