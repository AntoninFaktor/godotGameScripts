extends State
class_name enemyWander

@export var enemy: CharacterBody2D
var player: CharacterBody2D
var move_speed : int
var move_direction : Vector2
var wander_time : float
var animation_player: AnimationPlayer
var sprite: Sprite2D
var enter_vacinity_range: int

func randomize_wander() -> void:
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1, 3)
	
func Enter() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_player = enemy.get_node('AnimationPlayer')
	animation_player.play('move')
	sprite = enemy.get_node('Sprite2D')
	randomize_wander()
	move_speed = enemy.move_speed*.6
	enter_vacinity_range = enemy.enter_vacinity_range

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
		if enemy.velocity.x > 0:
			sprite.flip_h = false
		elif enemy.velocity.x < 0:
			sprite.flip_h = true
	
	var direction: Vector2 = player.global_position - enemy.global_position
	
	if direction.length() < enter_vacinity_range:
		Transitioned.emit(self, 'enemyFollow')
