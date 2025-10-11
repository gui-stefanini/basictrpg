class_name SummonAction
extends Action
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

@export var AnimationName: String
@export var SummonList: Array[SpawnInfo]

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

func _on_select(user: Unit, manager: GameManager):
	manager.MyActionManager.HighlightArea(user, ActionManager.HighlightTypes.SUPPORT, 0, true)
	manager.MyCursor.Disable()
	#manager.MyActionManager.ExecuteAction(self, user)

func _check_target(_user: Unit, _manager: GameManager = null, _target = null) -> bool:
	return true

func _execute(user: Unit, manager: GameManager, _target = null, _simulation : bool = false) -> Variant:
	print(user.Data.Name + " summons!")
	
	for summon in SummonList:
		summon.Summoner = user
		
		match user.Faction:
			Unit.Factions.PLAYER:
				summon.Faction = Unit.Factions.PLAYER_SUMMON
			Unit.Factions.ALLY:
				summon.Faction = Unit.Factions.ALLY_SUMMON
			Unit.Factions.ENEMY:
				summon.Faction = Unit.Factions.ENEMY_SUMMON
		
		summon.Position =  manager.GroundGrid.local_to_map(user.global_position)
	
	await user.PlayActionAnimation(AnimationName, user)
	user.summoned_units.emit()
	manager.SpawnUnitGroup(SummonList)
	
	user.HasActed = true
	return null

##############################################################
#                      4.0 Godot Functions                   #
##############################################################
