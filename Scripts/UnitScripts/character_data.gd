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
@export var Summon: bool = false

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
@export var CharacterAbilities: Array[Ability]
@export var CharacterActions: Array[Action]
@export var CharacterMovementType: MovementData

var Abilities: Array[Ability]
var Actions: Array[Action]
var MovementType: MovementData

#Animation
@export var CharacterSpriteSheet: Texture2D
@export var CharacterHframes: int = 0
@export var CharacterVframes: int = 0
@export var CharacterAnimationLibrary: AnimationLibrary

var SpriteSheet: Texture2D
var Hframes: int = 0
var Vframes: int = 0
var MyAnimationLibrary: AnimationLibrary

#AI Helper
@export var CharacterAIActions: Dictionary
var AIActions: Dictionary

#Save
var InfoToSave: Array[String] = ["CharacterLevel"]

##############################################################
#                      2.0 Functions                         #
##############################################################
func NameOverride():
	if Generic == true:
		Name += Class.Name
		if Boss == true:
			Name += " Boss"

func AbilitiesOverride():
	Abilities.clear()
	var all_abilities = GeneralFunctions.AddUniqueArrays(CharacterAbilities, Class.ClassAbilities) as Array[Ability]
	for ability in all_abilities:
		Abilities.append(ability as Ability)

func ActionsOverride():
	Actions.clear()
	var all_actions = GeneralFunctions.AddUniqueArrays(CharacterActions, Class.ClassActions) as Array[Action]
	for action in all_actions:
		Actions.append(action as Action)

func MovementOverride():
	if CharacterMovementType == null: 
		MovementType = Class.ClassMovementType
	else:
		MovementType = CharacterMovementType

func SpriteOverride():
	if CharacterSpriteSheet == null: 
		SpriteSheet = Class.ClassSpriteSheet
		Hframes = Class.Hframes
		Vframes = Class.Vframes
	
	else:
		SpriteSheet = CharacterSpriteSheet
		Hframes = CharacterHframes
		Vframes = CharacterVframes
		
	if CharacterAnimationLibrary == null:
		MyAnimationLibrary = Class.MyAnimationLibrary
	else:
		MyAnimationLibrary = CharacterAnimationLibrary

func AIOverride():
	AIActions = Class.ClassAIActions.duplicate()
	
	for action in CharacterAIActions:
		AIActions[action] = CharacterAIActions[action]

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
	AIOverride()
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
