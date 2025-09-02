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

#BaseStats
var BaseMaxHP: int
var BaseAttackPower: int
var BaseHealPower: int

var BaseMoveRange: int
var BaseAttackRange: int
var BaseAggro: int
var BaseSupportAggro: int

#Info
@export var Abilities: Array[Ability]
@export var Actions: Array[Action]
@export var MovementType: MovementData

#Animation
@export var CharacterSpriteSheet: Texture2D
@export var Hframes: int = 0
@export var Vframes: int = 0
@export var MyAnimationLibrary: AnimationLibrary



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

func SetStats():
	#int() correctly ignores decimals
	BaseMaxHP = CharacterMaxHP + Class.ClassMaxHP + int(Class.ClassGrowthMaxHP * (CharacterLevel-1))
	BaseAttackPower = CharacterAttackPower + Class.ClassAttackPower + int(Class.ClassGrowthAttackPower * (CharacterLevel-1))
	BaseHealPower = CharacterHealPower + Class.ClassHealPower + int(Class.ClassGrowthHealPower * (CharacterLevel-1))
	
	BaseMoveRange = CharacterMoveRange + Class.ClassMoveRange
	BaseAttackRange = CharacterAttackRange + Class.ClassAttackRange 
	BaseAggro = CharacterAggro + Class.ClassAggro
	BaseSupportAggro = CharacterSupportAggro + Class.ClassSupportAggro 

func ClassOverride():
	NameOverride()
	AbilitiesOverride()
	ActionsOverride()
	MovementOverride()
	SpriteOverride()
	SetStats()

func LevelUp():
	if CharacterLevel < 3:
		CharacterLevel += 1
	SetStats()

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
