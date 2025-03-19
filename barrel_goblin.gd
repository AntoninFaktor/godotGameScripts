extends CharacterBody2D
class_name barrelGoblin

@export var dmg: int = 2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')

func _physics_process(delta: float) -> void:
	if player.velocity.length() == 0:
		velocity = Vector2.ZERO
	move_and_slide()

	if velocity.length() > 0:
		animation_player.play("move")
		
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
	else:
		animation_player.play("idle")
