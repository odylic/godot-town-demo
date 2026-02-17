extends Control

const WORLD_W := 2400.0
const WORLD_H := 1800.0

# The world is divided into a 2×2 grid of logical "screens"
const SCREEN_COLS := 2
const SCREEN_ROWS := 2

# Name for each screen cell [row][col]
const SCREEN_NAMES := [
	["Town Square",  "Tavern District"],
	["South Quarter", "Merchant Quarter"],
]

# Building rects [x1, y1, x2, y2, color_index]
const BUILDINGS := [
	[200.0, 150.0, 350.0, 300.0, 0],   # House1
	[800.0, 200.0, 1000.0, 400.0, 1],  # House2
	[450.0, 450.0, 650.0, 650.0, 2],   # Shop
	[1400.0, 800.0, 1600.0, 1000.0, 3], # House3
	[1800.0, 200.0, 2050.0, 500.0, 4], # Tavern
	[300.0, 1200.0, 500.0, 1400.0, 5], # House4
]

const BUILDING_COLORS := [
	Color(0.6, 0.3, 0.1),
	Color(0.5, 0.4, 0.3),
	Color(0.7, 0.5, 0.3),
	Color(0.5, 0.35, 0.2),
	Color(0.45, 0.3, 0.15),
	Color(0.55, 0.4, 0.25),
]

const BUILDING_NAMES := ["House 1", "House 2", "Shop", "House 3", "Tavern", "House 4"]

const ROADS := [
	[300.0, 320.0, 980.0, 420.0],
	[1100.0, 600.0, 2200.0, 700.0],
]

func _draw() -> void:
	var w := size.x
	var h := size.y
	var cell_w := w / SCREEN_COLS
	var cell_h := h / SCREEN_ROWS

	var font := ThemeDB.fallback_font
	var name_size := 14
	var label_size := 11

	# Ground base
	draw_rect(Rect2(0, 0, w, h), Color(0.15, 0.45, 0.15))

	# Highlight the cell the player is currently in
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var px: float = (players[0] as Node2D).position.x
		var py: float = (players[0] as Node2D).position.y
		var col: int = clamp(int(px / (WORLD_W / SCREEN_COLS)), 0, SCREEN_COLS - 1)
		var row: int = clamp(int(py / (WORLD_H / SCREEN_ROWS)), 0, SCREEN_ROWS - 1)
		draw_rect(
			Rect2(col * cell_w, row * cell_h, cell_w, cell_h),
			Color(0.35, 0.65, 0.35, 0.45)
		)

	# Roads
	for road in ROADS:
		draw_rect(_world_rect(road[0], road[1], road[2], road[3], w, h), Color(0.35, 0.35, 0.35))

	# Buildings with subtle border
	for i in range(BUILDINGS.size()):
		var b: Array = BUILDINGS[i]
		var r := _world_rect(b[0], b[1], b[2], b[3], w, h)
		draw_rect(r, BUILDING_COLORS[b[4]])
		draw_rect(r, Color(0.0, 0.0, 0.0, 0.45), false, 1.0)
		# Label if building is wide enough
		if r.size.x > 28:
			draw_string(
				font,
				Vector2(r.position.x + 2, r.position.y + r.size.y * 0.5 + label_size * 0.35),
				BUILDING_NAMES[i],
				HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 4, label_size,
				Color(1.0, 1.0, 1.0, 0.9)
			)

	# Screen grid dividers — bright yellow lines
	for col in range(1, SCREEN_COLS):
		var x := col * cell_w
		draw_line(Vector2(x, 0), Vector2(x, h), Color(0.95, 0.95, 0.2, 0.9), 2.0)
	for row in range(1, SCREEN_ROWS):
		var y := row * cell_h
		draw_line(Vector2(0, y), Vector2(w, y), Color(0.95, 0.95, 0.2, 0.9), 2.0)

	# Screen zone name labels
	for row in range(SCREEN_ROWS):
		for col in range(SCREEN_COLS):
			var label_str: String = SCREEN_NAMES[row][col]
			var tx := col * cell_w + 6.0
			var ty := row * cell_h + name_size + 4.0
			# Shadow
			draw_string(font, Vector2(tx + 1, ty + 1), label_str,
				HORIZONTAL_ALIGNMENT_LEFT, cell_w - 12, name_size, Color(0, 0, 0, 0.8))
			# Label
			draw_string(font, Vector2(tx, ty), label_str,
				HORIZONTAL_ALIGNMENT_LEFT, cell_w - 12, name_size, Color(1.0, 1.0, 0.7, 1.0))

	# Outer border
	draw_rect(Rect2(0, 0, w, h), Color(0.65, 0.65, 0.65), false, 2.0)

	# NPCs — yellow circles
	for npc in get_tree().get_nodes_in_group("npcs"):
		var mp: Vector2 = _world_pos((npc as Node2D).position, w, h)
		draw_circle(mp, 6.0, Color(1.0, 0.9, 0.0))
		draw_circle(mp, 2.5, Color(0.4, 0.35, 0.0))

	# Player — blue circle with white centre
	if players.size() > 0:
		var mp: Vector2 = _world_pos((players[0] as Node2D).position, w, h)
		draw_circle(mp, 8.0, Color(0.2, 0.55, 1.0))
		draw_circle(mp, 3.5, Color(1.0, 1.0, 1.0))

func _world_rect(x1: float, y1: float, x2: float, y2: float, w: float, h: float) -> Rect2:
	return Rect2(
		x1 / WORLD_W * w, y1 / WORLD_H * h,
		(x2 - x1) / WORLD_W * w, (y2 - y1) / WORLD_H * h
	)

func _world_pos(world_pos: Vector2, w: float, h: float) -> Vector2:
	return Vector2(world_pos.x / WORLD_W * w, world_pos.y / WORLD_H * h)
