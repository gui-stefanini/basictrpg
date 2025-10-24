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

var MyGameManager: GameManager

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################
func Initialize(manager: GameManager):
	MyGameManager = manager

func GetCurrentArray() -> Array[Unit]:
	match MyGameManager.CurrentGameState:
		MyGameManager.GameState.ALLY_TURN:
			return UnitManager.CompleteAllyUnits
		MyGameManager.GameState.ENEMY_TURN:
			return UnitManager.CompleteEnemyUnits
		MyGameManager.GameState.WILD_TURN:
			return UnitManager.CompleteWildUnits
		_:
			push_error("wrong CurrentGameState for turn manager's get array")
			return []

func ContinueCurrentTurn():
	var faction_array: Array[Unit] = GetCurrentArray()
	var current_unit: Unit = null
	
	for unit in faction_array:
		if unit.HasActed == false:
			current_unit = unit
			break
	
	if current_unit != null:
		MyGameManager.MyGameCamera.MoveCamera(current_unit.CurrentTile)
		await GeneralFunctions.Wait(0.2)
		await current_unit.MyAI.Behavior.ExecuteTurn(current_unit, MyGameManager)
		MyGameManager.unit_turn_ended.emit(current_unit, current_unit.CurrentTile)
		await MyGameManager.CurrentLevelManager.unit_turn_ended_completed
		ContinueCurrentTurn()
		return
	
	else:
		EndCurrentTurn()

func EndCurrentTurn():
	match MyGameManager.CurrentGameState:
		MyGameManager.GameState.ALLY_TURN:
			MyGameManager.EndAllyTurn()
			return
		MyGameManager.GameState.ENEMY_TURN:
			MyGameManager.EndEnemyTurn()
			return
		MyGameManager.GameState.WILD_TURN:
			MyGameManager.EndWildTurn()
			return
		_:
			push_error("wrong CurrentGameState for turn manager's end turn")
			return

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
