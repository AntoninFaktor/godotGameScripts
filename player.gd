extends CharacterBody2D

@onready var pawn_sprite: Sprite2D = $pawnSprite
@onready var animated_sprite: AnimationPlayer = $AnimationPlayer
var damaged_sfx: Array = []
@onready var damaged: AudioStreamPlayer2D = $Damaged
@onready var damaged_2: AudioStreamPlayer2D = $Damaged2
@onready var damaged_3: AudioStreamPlayer2D = $Damaged3
@onready var died: AudioStreamPlayer2D = $Died


var next_state: String
var current_health: int = 3
var is_dead: bool = false
var is_carrying: bool = false

func _ready() -> void:
	damaged_sfx = [damaged, damaged_2, damaged_3]

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
	MotionMode.MOTION_MODE_FLOATING
	move_and_collide(velocity * delta)

func _on_health_component_current_health(health: Variant) -> void:
	if current_health != health:
		var tween = get_tree().create_tween()
		tween.tween_method(set_shader_blink_intensity, 1.0, 0.0, 0.5)
	current_health = health

func set_shader_blink_intensity(newValue: float) -> void:
	get_node('pawnSprite').material.set_shader_parameter('blink_intesity', newValue )


func _on_health_component_damage_taken() -> void:
	var sound_sfx = damaged_sfx.pick_random()
	sound_sfx.pitch_scale=randf_range(.8, 1)
	sound_sfx.play()
