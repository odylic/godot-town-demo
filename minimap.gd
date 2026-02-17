extends Control

const WORLD_W := 2400.0
const WORLD_H := 1800.0

# Dirt path running through the overworld (full height)
const OVERWORLD_PATH := [1100.0, 0.0, 1300.0, 1800.0]

# Gray wall strips flanking the exit doorway [x1, y1, x2, y2]
const TOWN_EXIT_WALLS := [
	[0.0, 0.0, 1100.0, 120.0],
	[1300.0, 0.0, 2400.0, 120.0],
]
const OVERWORLD_EXIT_WALLS := [
	[0.0, 1680.0, 1100.0, 1800.0],
	[1300.0, 1680.0, 2400.0, 1800.0],
]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	var scene_path: String = get_tree().current_scene.scene_file_path
	var is_town := scene_path.ends_with("main.tscn")

	# Ground — match each scene's actual color
	if is_town:
		draw_rect(Rect2(0, 0, w, h), Color(0.2, 0.6, 0.2))
	else:
		draw_rect(Rect2(0, 0, w, h), Color(0.08, 0.28, 0.08))
		# Dirt path through center of overworld
		draw_rect(_world_rect(OVERWORLD_PATH[0], OVERWORLD_PATH[1], OVERWORLD_PATH[2], OVERWORLD_PATH[3], w, h), Color(0.38, 0.3, 0.18))

	# Buildings — auto-detected from "buildings" group (house Floor ColorRects)
	if is_town:
		for b in get_tree().get_nodes_in_group("buildings"):
			if b is ColorRect:
				var rect := b as ColorRect
				var gp := rect.global_position
				draw_rect(_world_rect(gp.x, gp.y, gp.x + rect.size.x, gp.y + rect.size.y, w, h), rect.color)

	# Exit walls — gray strips flanking the doorway opening
	var exit_walls := TOWN_EXIT_WALLS if is_town else OVERWORLD_EXIT_WALLS
	for wall in exit_walls:
		draw_rect(_world_rect(wall[0], wall[1], wall[2], wall[3], w, h), Color(0.45, 0.45, 0.45))

	# Screen grid lines — yellow dashes showing the 2×2 screen divisions
	draw_line(Vector2(w * 0.5, 0.0), Vector2(w * 0.5, h), Color(0.9, 0.9, 0.2, 0.5), 0.5)
	draw_line(Vector2(0.0, h * 0.5), Vector2(w, h * 0.5), Color(0.9, 0.9, 0.2, 0.5), 0.5)

	# NPCs — yellow dots
	for npc in get_tree().get_nodes_in_group("npcs"):
		draw_circle(_world_pos((npc as Node2D).global_position, w, h), 2.5, Color(1.0, 0.9, 0.0))

	# Player — blue dot with white centre
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var mp: Vector2 = _world_pos((players[0] as Node2D).global_position, w, h)
		draw_circle(mp, 4.0, Color(0.3, 0.6, 1.0))
		draw_circle(mp, 1.5, Color(1.0, 1.0, 1.0))

	# Border
	draw_rect(Rect2(0, 0, w, h), Color(0.7, 0.7, 0.7), false, 1.0)

func _world_rect(x1: float, y1: float, x2: float, y2: float, w: float, h: float) -> Rect2:
	return Rect2(
		x1 / WORLD_W * w, y1 / WORLD_H * h,
		(x2 - x1) / WORLD_W * w, (y2 - y1) / WORLD_H * h
	)

func _world_pos(world_pos: Vector2, w: float, h: float) -> Vector2:
	return Vector2(world_pos.x / WORLD_W * w, world_pos.y / WORLD_H * h)
