extends Node2D

func _ready() -> void:
	$RightExit.body_entered.connect(_on_right_exit)

func _on_right_exit(body: Node2D) -> void:
	if body.is_in_group("player"):
		GlobalState.spawn_position = Vector2(50.0, 900.0)
		get_tree().change_scene_to_file("res://main.tscn")
