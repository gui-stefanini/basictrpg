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
@export var CharacterLevel: int = 1
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
	#int() correctly ignores decimals
	get: return CharacterMaxHP + Class.ClassMaxHP + int(Class.ClassGrowthMaxHP * (CharacterLevel-1))
var BaseAttackPower: int:
	get: return CharacterAttackPower + Class.ClassAttackPower + int(Class.ClassGrowthAttackPower * (CharacterLevel-1))
var BaseHealPower: int:
	get: return CharacterHealPower + Class.ClassHealPower + int(Class.ClassGrowthHealPower * (CharacterLevel-1))

var BaseMoveRange: int:
	get: return CharacterMoveRange + Class.ClassMoveRange
var BaseAttackRange: int:
	get: return CharacterAttackRange + Class.ClassAttackRange 
var BaseAggro: int:
	get: return CharacterAggro + Class.ClassAggro
var BaseSupportAggro: int:
	get: return CharacterSupportAggro + Class.ClassSupportAggro 

##############################################################
#                      2.0 Functions                         #
##############################################################
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

func ClassOverride():
	NameOverride()
	AbilitiesOverride()
	ActionsOverride()
	MovementOverride()
	SpriteOverride()

func LevelUP():
	if CharacterLevel < 3:
		CharacterLevel += 1

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
