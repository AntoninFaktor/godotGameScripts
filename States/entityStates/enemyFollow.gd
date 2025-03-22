extends State
class_name enemyFollow

@export var enemy: CharacterBody2D
@export var sneak: bool = false

var move_speed : int
var start_attacking: int
var player: CharacterBody2D
var animation_player: AnimationPlayer
var sprite: Sprite2D
var exit_vacinity_range: int

func Enter() -> void:
	player = get_tree().get_first_node_in_group('player')
	animation_player = enemy.get_node('AnimationPlayer')
	sprite = enemy.get_node('Sprite2D')
	move_speed = enemy.move_speed
	start_attacking = enemy.range
	exit_vacinity_range = enemy.exit_vacinity_range
	
func Physics_Update(delta: float) -> void:
	var direction: Vector2 = player.global_position - enemy.global_position

	if enemy.velocity.x > 0:
		sprite.flip_h = false
	elif enemy.velocity.x < 0:
		sprite.flip_h = true
	
	if direction.length() > 60:
		if sneak and player.velocity.length() == 0:
			enemy.velocity=Vector2.ZERO
			animation_player.play('idle')
		else:
			enemy.velocity = direction.normalized() * move_speed
			animation_player.play('move')
			
	elif direction.length() <= start_attacking:
		enemy.velocity = Vector2(0,0)
		Transitioned.emit(self, 'enemyAttack')
	
	if direction.length() > exit_vacinity_range:
		Transitioned.emit(self, str(get_parent().get_child(0).name))
