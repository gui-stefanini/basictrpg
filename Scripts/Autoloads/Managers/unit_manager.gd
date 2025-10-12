extends Node

##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

var PlayerUnits: Array[Unit] = []
var PlayerSummonUnits: Array[Unit] = []
var CompletePlayerUnits: Array[Unit] = []
var AllyUnits: Array[Unit] = []
var AllySummonUnits: Array[Unit] = []
var CompleteAllyUnits: Array[Unit] = []
var EnemyUnits: Array[Unit] = []
var EnemySummonUnits: Array[Unit] = []
var CompleteEnemyUnits: Array[Unit] = []
var WildUnits: Array[Unit] = []
var CompleteWildUnits: Array[Unit] = []

var FriendlyUnits: Array[Unit] = []
var OpposingUnits: Array[Unit] = []
var NeutralUnits: Array[Unit] = []

var NonSummonedUnits: Array[Unit] = []

var AllUnits: Array[Unit] = []

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################
##############################################################
#                        2.1 ARRAYS                          #
##############################################################

func UpdateArrays():
	CompletePlayerUnits = PlayerUnits + PlayerSummonUnits
	CompleteAllyUnits = AllyUnits + AllySummonUnits
	CompleteEnemyUnits = EnemyUnits + EnemySummonUnits
	CompleteWildUnits = WildUnits
	
	FriendlyUnits = CompletePlayerUnits + CompleteAllyUnits
	OpposingUnits = CompleteEnemyUnits
	NeutralUnits = CompleteWildUnits
	
	NonSummonedUnits = PlayerUnits + AllyUnits + EnemyUnits + WildUnits
	
	AllUnits = FriendlyUnits + OpposingUnits + NeutralUnits

func AddUnit(unit: Unit):
	match unit.Faction:
		Unit.Factions.PLAYER:
			PlayerUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.FRIENDLY
		Unit.Factions.PLAYER_SUMMON:
			PlayerSummonUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.FRIENDLY
		Unit.Factions.ALLY:
			AllyUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.FRIENDLY
		Unit.Factions.ALLY_SUMMON:
			AllySummonUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.FRIENDLY
		
		Unit.Factions.ENEMY:
			EnemyUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.OPPOSING
		Unit.Factions.ENEMY_SUMMON:
			EnemySummonUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.OPPOSING
		
		Unit.Factions.WILD:
			WildUnits.append(unit)
			unit.Affiliation = Unit.Affiliations.NEUTRAL
	
	UpdateArrays()

func RemoveUnit(unit: Unit):
	if AllUnits.has(unit):
		match unit.Affiliation:
			Unit.Affiliations.FRIENDLY:
				match unit.Faction:
					Unit.Factions.PLAYER:
						PlayerUnits.erase(unit)
					Unit.Factions.PLAYER_SUMMON:
						PlayerSummonUnits.erase(unit)
					Unit.Factions.ALLY:
						AllyUnits.erase(unit)
					Unit.Factions.ALLY_SUMMON:
						AllySummonUnits.erase(unit)
			
			Unit.Affiliations.OPPOSING:
				match unit.Faction:
					Unit.Factions.ENEMY:
						EnemyUnits.erase(unit)
					Unit.Factions.ENEMY_SUMMON:
						EnemySummonUnits.erase(unit)
			
			Unit.Affiliations.NEUTRAL:
				match unit.Faction:
					Unit.Factions.WILD:
						WildUnits.erase(unit)
		
		UpdateArrays()
	
	else:
		push_error("unit not found by UnitManager")

func ClearArrays():
	PlayerUnits.clear()
	PlayerSummonUnits.clear()
	AllyUnits.clear()
	AllySummonUnits.clear()
	EnemyUnits.clear()
	EnemySummonUnits.clear()
	WildUnits.clear()
	
	UpdateArrays()

##############################################################
#                  2.2 AFFILIATION CHECK                     #
##############################################################

func GetHostileArray(unit: Unit) -> Array[Unit]:
	var hostile_array : Array[Unit] = []
	
	match unit.Affiliation:
		Unit.Affiliations.FRIENDLY:
			hostile_array = OpposingUnits + NeutralUnits
		Unit.Affiliations.OPPOSING:
			hostile_array = FriendlyUnits + NeutralUnits
		Unit.Affiliations.NEUTRAL:
			hostile_array = FriendlyUnits + OpposingUnits
	
	return hostile_array

func GetAffiliationArray(unit: Unit)-> Array[Unit]:
	match unit.Affiliation:
		Unit.Affiliations.FRIENDLY:
			return FriendlyUnits
		Unit.Affiliations.OPPOSING:
			return OpposingUnits
		Unit.Affiliations.NEUTRAL:
			return NeutralUnits
	
	return []

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
