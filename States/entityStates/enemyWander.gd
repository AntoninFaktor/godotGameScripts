extends State
class_name enemyWander

@export var enemy: CharacterBody2D
@export var move_speed: int = 75
var player: CharacterBody2D

var move_direction : Vector2
var wander_time : float

func randomize_wander() -> void:
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1, 3)
	
func Enter() -> void:
	player = get_tree().get_first_node_in_group("player")
	randomize_wander()

func Update(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
	
func Physics_Update(delta: float) -> void:
	if enemy:
		if enemy.is_on_ceiling() || enemy.is_on_floor() || enemy.is_on_wall():
			move_direction = move_direction * -1
		enemy.velocity = move_direction * move_speed
		
	var direction: Vector2 = player.global_position - enemy.global_position
	
	if direction.length() < 250:
		Transitioned.emit(self, 'enemyFollow')
