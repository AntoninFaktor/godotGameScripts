extends State
class_name enemyFollow

@export var enemy: CharacterBody2D
@export var sneak: bool = false

var move_speed : int
var attack_range: int
var player: CharacterBody2D
var animation_player: AnimationPlayer
var sprite: Sprite2D
var leave_alert_range: int

func Enter() -> void:
	player = get_tree().get_first_node_in_group('player')
	animation_player = enemy.get_node('AnimationPlayer')
	sprite = enemy.get_node('Sprite2D')
	move_speed = enemy.move_speed
	attack_range = enemy.attack_range
	leave_alert_range = enemy.leave_alert_range
	
func Physics_Update(delta: float) -> void:
	var direction: Vector2 = player.global_position - enemy.global_position

	if enemy.velocity.x > 0:
		sprite.flip_h = false
	elif enemy.velocity.x < 0:
		sprite.flip_h = true

	enemy.velocity = direction.normalized() * move_speed
	animation_player.play('move')
	
	if direction.length() < attack_range:
		Transitioned.emit(self, 'enemyAttack')
	elif direction.length() > leave_alert_range:
		Transitioned.emit(self, 'enemyWander')
		
		
