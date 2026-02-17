extends Node

# Set this before changing scenes to override the player's spawn position.
# (-1, -1) means "use the scene's default position".
var spawn_position: Vector2 = Vector2(-1.0, -1.0)

# Scene transition tracking for interior/exterior travel
var previous_scene: String = ""
var return_position: Vector2 = Vector2(-1.0, -1.0)
