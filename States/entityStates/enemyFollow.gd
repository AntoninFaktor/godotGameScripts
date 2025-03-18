extends State
class_name enemyFollow

@export var enemy: CharacterBody2D
@export var move_speed : int = 100
@export var stop_following: int = 300

var player: CharacterBody2D

func Enter() -> void:
	player = get_tree().get_first_node_in_group('player')
	
func Physics_Update(delta: float) -> void:
	var direction: Vector2 = player.global_position - enemy.global_position
	
	if direction.length() > 60:
		enemy.velocity = direction.normalized() * move_speed
	elif direction.length() <= 60:
		enemy.velocity = Vector2(0,0)
		Transitioned.emit(self, 'enemyAttack')
	
	if direction.length() > 300:
		Transitioned.emit(self, 'enemyWander')
