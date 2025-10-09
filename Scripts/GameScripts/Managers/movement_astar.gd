class_name MovementAStar
extends AStar2D
##############################################################
#                      0.0 Signals                           #
##############################################################

##############################################################
#                      1.0 Variables                         #
##############################################################
######################
#     REFERENCES     #
######################

var GroundGrid: TileMapLayer
var EffectLayer: TileMapLayer
var MovementType: MovementData

######################
#     SCRIPT-WIDE    #
######################

##############################################################
#                      2.0 Functions                         #
##############################################################

##############################################################
#                      3.0 Signal Functions                  #
##############################################################

##############################################################
#                      4.0 Godot Functions                   #
##############################################################

func _compute_cost(_from_id: int, to_id: int) -> float:
	var to_tile_coords = get_point_position(to_id)
	var tile_data = GroundGrid.get_cell_tile_data(to_tile_coords)
	var effect_tile_data = EffectLayer.get_cell_tile_data(to_tile_coords)
	if tile_data == null:
		return 1.0
	
	var terrain_type: String
	if effect_tile_data != null:
		terrain_type = effect_tile_data.get_custom_data("terrain_type")
	else:
		terrain_type = tile_data.get_custom_data("terrain_type")
	
	var cost = MovementType.TerrainCosts.get(terrain_type, INF)
	
	return float(cost)
