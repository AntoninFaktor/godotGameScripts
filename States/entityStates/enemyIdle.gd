extends State
class_name enemyIdle

@export var enemy: CharacterBody2D
@export var start_following: int = 500

var player: CharacterBody2D

func Enter() -> void:
	player = get_tree().get_first_node_in_group('player')
	enemy.velocity = Vector2.ZERO
	
func Physics_Update(delta: float) -> void:
	var direction: Vector2 = player.global_position - enemy.global_position
	
	if direction.length() < start_following:
		Transitioned.emit(self, 'enemyFollow')
