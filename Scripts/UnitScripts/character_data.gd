class_name CharacterData
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

@export var Class: ClassData
@export var Generic: bool = false
@export var Boss: bool = false
######################
#     SCRIPT-WIDE    #
######################
#Ignoring default order for Inspector
@export var Name: String = ""

#Stats
@export var CharacterMaxHP: int = 0
@export var CharacterAttackPower: int = 0
@export var CharacterHealPower: int = 0
@export var CharacterMoveRange: int = 0
@export var CharacterAttackRange: int = 0
@export var CharacterAggro: int = 0
@export var CharacterSupportAggro: int = 0

#Info
@export var Abilities: Array[Ability]
@export var Actions: Array[Action]
@export var MovementType: MovementData

#Animation
@export var CharacterSpriteSheet: Texture2D
@export var Hframes: int = 0
@export var Vframes: int = 0
@export var MyAnimationLibrary: AnimationLibrary

var BaseMaxHP: int:
	get: return Class.ClassMaxHP + CharacterMaxHP

var BaseAttackPower: int:
	get: return Class.ClassAttackPower + CharacterAttackPower

var BaseHealPower: int:
	get: return Class.ClassHealPower + CharacterHealPower

var BaseMoveRange: int:
	get: return Class.ClassMoveRange + CharacterMoveRange

var BaseAttackRange: int:
	get: return Class.ClassAttackRange + CharacterAttackRange

var BaseAggro: int:
	get: return Class.ClassAggro + CharacterAggro

var BaseSupportAggro: int:
	get: return Class.ClassSupportAggro + CharacterSupportAggro

##############################################################
#                      2.0 Functions                         #
##############################################################

func ClassOverride():
	NameOverride()
	AbilitiesOverride()
	ActionsOverride()
	MovementOverride()
	SpriteOverride()

func NameOverride():
	if Generic == true:
		Name += Class.Name
		if Boss == true:
			Name += " Boss"

func AbilitiesOverride():
	Abilities.append_array(Class.ClassAbilities)

func ActionsOverride():
	Actions.append_array(Class.ClassActions)

func MovementOverride():
	if MovementType == null: 
		MovementType = Class.ClassMovementType

func SpriteOverride():
	if CharacterSpriteSheet == null: 
		CharacterSpriteSheet = Class.ClassSpriteSheet
		Hframes = Class.Hframes
		Vframes = Class.Vframes
	if MyAnimationLibrary == null:
		MyAnimationLibrary = Class.MyAnimationLibrary

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
