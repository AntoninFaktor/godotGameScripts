extends State
class_name playerCarryMove

@export var player: CharacterBody2D
@export var move_speed: int
	
func Exit () -> void:
	player.velocity = Vector2( 0,0)

func Update(delta: float) -> void:
	if player.is_dead:
		Transitioned.emit(self, 'playerDied')
	if !player.is_carrying:
		Transitioned.emit(self, 'playerMove')
	
func Physics_Update(delta: float) -> void:
	player.animated_sprite.play('carry_move')
	player.get_node('AudioStreamPlayer2D2').pitch_scale=randf_range(.8, .95)
	var input_direction : Vector2 = Input.get_vector('right', 'left', 'up', 'down') * Vector2 (-1, 1)
	if input_direction.length() !=0:
		player.velocity = input_direction * move_speed
		if input_direction.x < 0:
			player.get_node('pawnSprite').flip_h = true
		elif input_direction.x > 0:
			player.get_node('pawnSprite').flip_h = false
	else:
		player.velocity = Vector2( 0,0)
		Transitioned.emit(self, player.next_state)
	
