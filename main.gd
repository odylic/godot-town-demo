extends Node2D

func _ready() -> void:
	$TopExit.body_entered.connect(_on_top_exit)

func _on_top_exit(body: Node2D) -> void:
	if body.is_in_group("player"):
		GlobalState.spawn_position = Vector2(1200.0, 1750.0)
		get_tree().change_scene_to_file("res://overworld.tscn")
