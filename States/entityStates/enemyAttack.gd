extends State
class_name enemyAttack

@export var enemy: CharacterBody2D
var player: CharacterBody2D
signal is_attacking(attack_direction)

func Enter() -> void:
	player = get_tree().get_first_node_in_group('player')
	enemy.velocity = Vector2.ZERO
	
func Physics_Update(delta: float) -> void:
	var direction: Vector2 = player.global_position - enemy.global_position
	var attack_direction: String
	enemy.get_node('AudioStreamPlayer2D').pitch_scale=randf_range(.9, 1.1)
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			enemy.get_node('Sprite2D').flip_h = true
			enemy.get_node('hitbox').scale.x = -1
		else:
			enemy.get_node('Sprite2D').flip_h = false
			enemy.get_node('hitbox').scale.x = 1
		attack_direction = 'attack_horizontal'
	elif direction.y < 0:
		attack_direction = 'attack_up'
	elif direction.y > 0:
		attack_direction = 'attack_down'
	
	if direction.length() > 60:
		Transitioned.emit(self, 'enemyFollow')
	elif player.is_dead:
		enemy.get_node('AnimationPlayer').play('idle')
	else:
		is_attacking.emit(attack_direction)
