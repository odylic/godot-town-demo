extends Node2D

func _ready() -> void:
	$ExitDoor.body_entered.connect(_on_exit)

func _on_exit(body: Node2D) -> void:
	if body.is_in_group("player"):
		GlobalState.spawn_position = GlobalState.return_position
		get_tree().change_scene_to_file(GlobalState.previous_scene)
