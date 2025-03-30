extends CharacterBody2D
class_name Goblin2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_component: hitboxComponent = $hitboxComponent
@onready var hitbox: Area2D = $hitbox
@onready var sprite: Sprite2D = $Sprite
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var last_known_position: Vector2 = player.global_position
@onready var state_chart: StateChart = $StateChart
@onready var line_of_sight: RayCast2D = RayCast2D.new()
@onready var pathfinder: PathfinderComponent = $Components/PathfinderComponent

var is_dead: bool = false
var wander_time: float
var distance: Vector2

@export var avoidance_radius: int = 40
@export var goal_weight: float = 10.0
@export var avoidance_weight: float = 20.0
@export var repulsion_strenght: float = .75
var num_dir: int = 24
var last_known_velocity: Vector2 = Vector2.ZERO

#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int

func _ready():
	# Initialize raycasts for obstacle avoidance
	pathfinder.initialize_raycasts(num_dir, avoidance_radius)
	# Add a RayCast2D for line of sight
	line_of_sight.enabled = true
	add_child(line_of_sight)
	update_state()

func _physics_process(delta: float) -> void:
	distance = player.global_position - global_position
	get_next_state()
	if curr_state != next_state:
		update_state()
	move_and_slide()
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
	
func has_line_of_sight() -> bool:
		line_of_sight.target_position = player.global_position - global_position
		line_of_sight.force_raycast_update()
		return not line_of_sight.is_colliding()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack: Attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)


enum States {IDLE, WANDER, FOLLOW, ATTACK, DEAD}
@export var curr_state : States
var next_state: States

#region HANDLE STATES
func update_state() -> void:
	curr_state = next_state
	match curr_state:
		States.IDLE:
			state_chart.send_event('idle')
		States.WANDER:
			state_chart.send_event('wander')
		States.FOLLOW:
			state_chart.send_event('follow')
		States.ATTACK:
			state_chart.send_event('attack')
		States.DEAD:
			state_chart.send_event('dead')
			
func get_next_state() -> void:
	if is_dead:
		next_state = States.DEAD
	elif player.is_dead:
		next_state = States.IDLE
	elif distance.length() < attack_range:
		next_state = States.ATTACK
	elif distance.length() < alert_range and has_line_of_sight():
		next_state = States.FOLLOW
	elif distance.length() > leave_alert_range:
		next_state = States.WANDER
#endregion

#region IDLE STATE
func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play("idle")

func _on_to_wander_taken() -> void:
	next_state = States.WANDER

#endregion

@export var wander_radius: int = 20   	# Radius of the wander circle
@export var wander_distance: int = 50	# Distance of the wander circle from the enemy
@export var wander_jitter: int = 1   	# Amount of randomness added to the wander angle
@export var wander_angle: float 		# Current wander angle

#region WANDER STATE
func _on_wander_state_entered() -> void:
	animation_player.play('move')
	wander_time = randf_range(4, 10)
func _on_wander_state_physics_processing(delta: float) -> void:
	var forward: Vector2 = velocity.normalized()
	if forward == Vector2.ZERO:
		forward = Vector2(randf_range(-1,1), randf_range(-1,1))
	var circle_center: Vector2 = global_position + forward * wander_distance
	wander_angle += randf_range(-wander_jitter, wander_jitter)
	var offset_x: float = wander_radius * cos(wander_angle)
	var offset_y: float = wander_radius * sin(wander_angle)
	var wander_offset: Vector2 = Vector2(offset_x, offset_y)
	var target: Vector2 = circle_center + wander_offset
	if pathfinder.is_direction_blocked(target):
		target -= target
	var best_dir = pathfinder.get_best_direction(target, num_dir/2, repulsion_strenght, avoidance_radius, goal_weight, avoidance_weight)
	var desired_velocity: Vector2 = best_dir.normalized() * move_speed * .6
	velocity = velocity.lerp(desired_velocity, 0.1)  # Combine wander and avoidance
		
func _on_wander_state_processing(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	else:
		state_chart.send_event('idle')
		next_state = States.IDLE
#endregion

#region FOLLOW STATE
func _on_follow_state_entered() -> void:
	animation_player.play('move')

func _on_follow_state_processing(delta: float) -> void:
	var best_dir: Vector2
	if has_line_of_sight():
		last_known_position = player.global_position
		last_known_velocity = player.velocity.normalized()
		best_dir = pathfinder.get_best_direction(last_known_position, num_dir, repulsion_strenght, avoidance_radius, goal_weight, avoidance_weight)
	else:
		if global_position.distance_to(last_known_position) > 40:
			best_dir = pathfinder.get_best_direction(last_known_position, num_dir, repulsion_strenght, avoidance_radius, goal_weight, avoidance_weight)
		else:
				next_state = States.WANDER
	var desired_velocity = (best_dir).normalized() * move_speed
	velocity = velocity.lerp(desired_velocity, .33)
#endregion

#region ATTACK STATE
func enable_collision() -> void:
	$hitbox/CollisionShape2D.disabled = false
	
func _on_attack_state_entered() -> void:
	velocity = Vector2.ZERO

func _on_attack_state_physics_processing(delta: float) -> void:
	$AudioStreamPlayer2D.pitch_scale=randf_range(.8, 1.2)
	if distance.normalized().x < 0:
		sprite.flip_h = true
		hitbox.scale.x = -1
	if distance.normalized().x > 0:
		sprite.flip_h = false
		hitbox.scale.x = 1
	if abs(distance.x) > abs(distance.y):
		animation_player.play('attack_horizontal')
	elif distance.normalized().y < 0:
		animation_player.play('attack_up')
	elif distance.normalized().y > 0:
		animation_player.play('attack_down')

func _on_attack_state_exited() -> void:
	$hitbox/CollisionShape2D.disabled = true
#endregion

#region DEAD STATE
func _on_dead_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play('dead')
	
func clear_on_dead() -> void:
	queue_free()
#endregion
