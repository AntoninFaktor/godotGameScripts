extends State
class_name playerIdle

@export var player: CharacterBody2D
	
func Enter() -> void:
	player.velocity = Vector2(0, 0)
	
func Update(delta: float) -> void:
	if player.is_dead:
		Transitioned.emit(self, 'playerDied')
		
func Physics_Update(delta: float) -> void:
	
	if player.is_carrying:
		player.animated_sprite.play('carry_idle')
	else:
		player.animated_sprite.play('idle')
	Transitioned.emit(self, player.next_state)

	
