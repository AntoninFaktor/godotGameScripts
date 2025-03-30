extends CharacterBody2D
class_name barrelGoblin

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var state_chart: StateChart = $StateChart
@onready var distance: Vector2 = player.global_position - global_position
@onready var last_known_position: Vector2 = player.global_position
@onready var line_of_sight: RayCast2D = RayCast2D.new()
@onready var raycasts_node: Node2D = $Raycasts

#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int

var repulsion_dir: Vector2

@export var avoidance_radius: int = 40
@export var goal_weight: float = 10.0
@export var avoidance_weight: float = 20.0
@export var repulsion_strenght: float = .75
var num_dir: int = 36
var num_rays: int = 18
var directions: Array = []
var raycasts: Array = []
var last_known_velocity: Vector2 = Vector2.ZERO
@onready var is_ticked: bool = false

enum States {IDLE, FOLLOW, TICK}
@export var curr_state : States
var next_state: States

func _ready() -> void:
	for i in range(num_rays):
		var raycast: RayCast2D = RayCast2D.new()
		raycast.target_position = Vector2(cos(deg_to_rad(i * (360 / num_rays))), sin(deg_to_rad(i * (360 / num_rays)))) * avoidance_radius
		raycast.enabled = true
		raycasts.append(raycast)
		raycasts_node.add_child(raycast)
	# Add a RayCast2D for line of sight
	line_of_sight.enabled = true
	add_child(line_of_sight)

func _physics_process(delta: float) -> void:
	get_next_state()
	if curr_state != next_state:
		update_state()
	move_and_collide(velocity * delta)
	distance = player.global_position - global_position
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)
		
func has_line_of_sight() -> bool:
		line_of_sight.target_position = player.global_position - global_position
		line_of_sight.force_raycast_update()
		return not line_of_sight.is_colliding()
		
#region HANDLE STATES
func update_state() -> void:
	curr_state = next_state
	match curr_state:
		States.IDLE:
			state_chart.send_event('idle')
		States.FOLLOW:
			state_chart.send_event('follow')
		States.TICK:
			state_chart.send_event('tick')
			is_ticked = true
			
func get_next_state() -> void:
	if player.is_dead:
		next_state = States.IDLE
	elif distance.length() < attack_range:
		next_state = States.TICK
	elif distance.length() < alert_range and not has_line_of_sight():
		next_state = States.FOLLOW
	elif distance.length() < alert_range and player.velocity == Vector2.ZERO:
		next_state = States.FOLLOW
#endregion

#region IDLE STATE
func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play("idle")
#endregion

#region FOLLOW STATE
func generate_directions():
	directions.clear()
	#Generate possible directions for movement
	for i in range(num_dir):
		var angle = deg_to_rad(i * 360 / num_dir)
		directions.append(Vector2(cos(angle), sin(angle)))
		
func get_best_direction():
	generate_directions()
	var target_vector: Vector2 = last_known_position - global_position
	var best_direction: Vector2 = Vector2.ZERO
	var best_score: float = -float("inf")
	
	for dir in directions:
		var dir_normalized: Vector2 = dir.normalized()
		var goal_attraction: float = target_vector.normalized().dot(dir_normalized)
		var obstacle_penalty: int = 0
		if is_direction_blocked(dir):
			obstacle_penalty = 10
		var distance_to_goal: float = (global_position + dir).distance_to(last_known_position)*.1
		var distance_penalty: float = distance_to_goal / avoidance_radius
		if goal_attraction < 0:
			distance_penalty *= 0.5
		var score: float = (goal_weight * goal_attraction) - (avoidance_weight * obstacle_penalty) - distance_penalty
		if score > best_score:
			best_direction = dir
			best_score = score
	
	return best_direction
	
func is_direction_blocked(direction: Vector2) -> bool:
	for raycast in raycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var raycast_dir = raycast.target_position.normalized()
			if raycast_dir.dot(direction.normalized()) > 0.9:
				return true
	return false

func _on_follow_state_entered() -> void:
	animation_player.play('move')

func _on_follow_state_processing(delta: float) -> void:
	var best_dir: Vector2
	last_known_position = player.global_position
	last_known_velocity = player.velocity.normalized()
	if not has_line_of_sight():
		best_dir = get_best_direction() + last_known_velocity
	else:
		if player.velocity == Vector2.ZERO:
			best_dir = get_best_direction()+last_known_velocity
		else:
				next_state = States.IDLE
	var desired_velocity = (best_dir+repulsion_dir).normalized() * move_speed
	velocity = velocity.lerp(desired_velocity, .33)
#endregion

#region TICK STATE
func _on_tick_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play('attack')
	await get_tree().create_timer(2.6).timeout
	queue_free()
#endregion
