class_name MovementData
extends Resource

# A dictionary where keys are terrain type strings (e.g., "Grass")
# and values are the movement cost integers.
@export var Name : String
@export var TerrainCosts: Dictionary = {"Grass": 1, "Water": 1, "Obstacle": 1}
