extends CharacterBody2D

const SPEED = 200.0

func _ready() -> void:
	add_to_group("player")
	if GlobalState.spawn_position.x >= 0.0:
		position = GlobalState.spawn_position
		GlobalState.spawn_position = Vector2(-1.0, -1.0)

func _physics_process(_delta):
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Set velocity
	velocity = direction * SPEED

	# Move
	move_and_slide()
