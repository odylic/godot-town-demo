extends StaticBody2D

@export var npc_name: String = "Villager"
@export var dialogue_lines: Array[String] = [
	"Hello there! Welcome to our town.",
	"It's a lovely day, isn't it?",
	"We've been having great weather lately.",
	"Come back and visit anytime!"
]
# Shift the interaction zone relative to the NPC (e.g. in front of a counter)
@export var interaction_offset: Vector2 = Vector2.ZERO
# Size of the interaction zone (defaults to npc.tscn's 80×80)
@export var interaction_size: Vector2 = Vector2(80, 80)

var player_nearby = false

func _ready():
	add_to_group("npcs")
	$InteractionArea.position = interaction_offset
	var col := $InteractionArea.get_child(0) as CollisionShape2D
	var shape := RectangleShape2D.new()
	shape.size = interaction_size
	col.shape = shape
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
		if dialogue_box and not dialogue_box.is_open():
			interact()

func _on_body_entered(body):
	if body.name == "Player":
		player_nearby = true
		body.get_node("InteractIndicator").visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false
		body.get_node("InteractIndicator").visible = false

func interact():
	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box:
		dialogue_box.show_dialogue(npc_name, dialogue_lines)
