extends State
class_name Idle

@export var enemy: CharacterBody2D


var animation_player: AnimationPlayer
var player: CharacterBody2D
var alert_range: int

func Enter() -> void:
	player = get_tree().get_first_node_in_group('player')
	enemy.velocity = Vector2.ZERO
	animation_player = enemy.get_node('AnimationPlayer')
	animation_player.play('idle')
	alert_range = enemy.alert_range
	
func Physics_Update(delta: float) -> void:
	var direction: Vector2 = player.global_position - enemy.global_position
	
	if direction.length() < alert_range:
		Transitioned.emit(self, 'enemyFollow')
