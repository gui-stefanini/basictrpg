class_name AIBehavior
extends Resource

# This is the "brain" function. It takes the unit that owns the AI (owner)
# and a reference to the main map script to access its helper functions.
# It needs to be async so it can wait for animations.
func execute_turn(owner: Unit, _map: Node2D):
	# Await is needed for the function to be async.
	await owner.get_tree().create_timer(0.01).timeout
	pass
