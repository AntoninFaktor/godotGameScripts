extends CharacterBody2D

@onready var pawn_sprite: Sprite2D = $pawnSprite

@onready var animated_sprite: AnimationPlayer = $AnimationPlayer

var next_state: String
var current_health: int = 3
var is_dead: bool = false
var is_carrying: bool = false

func handle_states() -> void:
	next_state = 'playerIdle'
	if is_dead:
		next_state = 'playerDied'
	if Input.is_action_pressed('attack'):
		next_state = 'playerAttack'
	if Input.get_vector('left', 'right', 'up', 'down') != Vector2.ZERO:
		next_state = 'playerMove'

func _physics_process(delta: float) -> void:
	handle_states()
	move_and_slide()

func _on_health_component_current_health(health: Variant) -> void:
	current_health = health
