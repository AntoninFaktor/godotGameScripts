extends State
class_name playerAttack

@export var player: CharacterBody2D
	
func Enter() -> void:
	player.velocity = Vector2(0, 0)
	player.animated_sprite.play('attack')

func Update(delta: float) -> void:
	if player.is_dead:
		Transitioned.emit(self, 'playerDied')
	
func Physics_Update(delta: float) -> void:
	Transitioned.emit(self, player.next_state)
	
