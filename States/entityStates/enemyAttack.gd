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
	if abs(direction.x) > abs(direction.y):
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
		is_attacking.emit(attack_direction, direction)
		if get_parent().has_node('enemyTicking'):
			Transitioned.emit(self, 'enemyTicking')
		else:
			pass
		
		
