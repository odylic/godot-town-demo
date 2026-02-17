extends CanvasLayer

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		visible = !visible
	elif visible and event.is_action_pressed("ui_cancel"):
		visible = false

func _process(_delta: float) -> void:
	if visible:
		$MapPanel/MapDraw.queue_redraw()
