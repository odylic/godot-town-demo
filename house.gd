extends Node2D

@export var house_width: float = 150.0
@export var house_height: float = 150.0
@export var house_color: Color = Color(0.6, 0.3, 0.1)
@export var roof_color: Color = Color(0.4, 0.2, 0.1)
@export var interior_scene: String = ""
@export var sign_text: String = ""

func _ready() -> void:
	_build()

func _build() -> void:
	# Floor (the visible house body) — added to "buildings" group for minimap
	var floor_rect := ColorRect.new()
	floor_rect.name = "Floor"
	floor_rect.offset_left = 0.0
	floor_rect.offset_top = 0.0
	floor_rect.offset_right = house_width
	floor_rect.offset_bottom = house_height
	floor_rect.color = house_color
	add_child(floor_rect)
	floor_rect.add_to_group("buildings")

	# Roof strip above the house
	var roof := ColorRect.new()
	roof.name = "Roof"
	roof.offset_left = -10.0
	roof.offset_top = -30.0
	roof.offset_right = house_width + 10.0
	roof.offset_bottom = 0.0
	roof.color = roof_color
	add_child(roof)

	# Sign board above the roof (only when sign_text is set)
	if sign_text != "":
		var sign_w := house_width + 20.0
		var sign_bg := ColorRect.new()
		sign_bg.name = "Sign"
		sign_bg.offset_left = -10.0
		sign_bg.offset_top = -54.0
		sign_bg.offset_right = house_width + 10.0
		sign_bg.offset_bottom = -32.0
		sign_bg.color = Color(0.45, 0.28, 0.1)
		add_child(sign_bg)

		var label := Label.new()
		label.name = "SignLabel"
		label.text = sign_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.position = Vector2(-10.0, -54.0)
		label.size = Vector2(sign_w, 22.0)
		var settings := LabelSettings.new()
		settings.font_size = 12
		settings.font_color = Color(1.0, 0.95, 0.7)
		label.label_settings = settings
		add_child(label)

	# Door visual — centered at the bottom front of the house
	var door_w := 24.0
	var door_h := 36.0
	var door_x := (house_width - door_w) / 2.0
	var door_y := house_height - door_h
	var door_rect := ColorRect.new()
	door_rect.name = "Door"
	door_rect.offset_left = door_x
	door_rect.offset_top = door_y
	door_rect.offset_right = door_x + door_w
	door_rect.offset_bottom = door_y + door_h
	door_rect.color = Color(0.25, 0.15, 0.05)
	add_child(door_rect)

	# Walls — StaticBody2D with 5 segments leaving a door gap
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	add_child(walls)

	var wall_thickness := 8.0

	# Top wall (full width)
	_add_wall(walls, 0.0, 0.0, house_width, wall_thickness)

	# Left wall (full height)
	_add_wall(walls, 0.0, 0.0, wall_thickness, house_height)

	# Right wall (full height)
	_add_wall(walls, house_width - wall_thickness, 0.0, wall_thickness, house_height)

	# Front wall left of door gap
	var gap_left := door_x - 12.0
	if gap_left > wall_thickness:
		_add_wall(walls, 0.0, house_height - wall_thickness, gap_left, wall_thickness)

	# Front wall right of door gap
	var gap_right := door_x + door_w + 12.0
	if gap_right < house_width - wall_thickness:
		_add_wall(walls, gap_right, house_height - wall_thickness, house_width - gap_right, wall_thickness)

	# Door trigger — Area2D at the door opening
	var trigger := Area2D.new()
	trigger.name = "DoorTrigger"
	trigger.position = Vector2(door_x + door_w / 2.0, house_height)
	add_child(trigger)

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(door_w, 20.0)
	shape.shape = rect_shape
	trigger.add_child(shape)

	trigger.body_entered.connect(_on_door_entered)

func _add_wall(parent: StaticBody2D, x: float, y: float, w: float, h: float) -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	col.shape = rect
	# CollisionShape2D position is the center of the shape
	col.position = Vector2(x + w / 2.0, y + h / 2.0)
	parent.add_child(col)

func _on_door_entered(body: Node2D) -> void:
	if body.is_in_group("player") and interior_scene != "":
		GlobalState.previous_scene = get_tree().current_scene.scene_file_path
		GlobalState.return_position = Vector2(
			global_position.x + house_width / 2.0,
			global_position.y + house_height + 24.0
		)
		GlobalState.spawn_position = Vector2(640.0, 650.0)
		get_tree().change_scene_to_file(interior_scene)
