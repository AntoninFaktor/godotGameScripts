extends CharacterBody2D

class_name FollowState

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var raycasts_node: Node2D = $Raycasts
@onready var line_of_sight: RayCast2D = RayCast2D.new()
@onready var last_known_position: Vector2 = player.global_position

@export var move_speed: int = 50
@export var avoidance_radius: int = 40
@export var goal_weight: float = 10.0
@export var avoidance_weight: float = 20.0
@export var repulsion_strenght: float = .75
var num_dir: int = 36
var num_rays: int = 24

var directions: Array = []
var raycasts: Array = []
var last_known_velocity: Vector2 = Vector2.ZERO

func _ready():
	# Initialize raycasts for obstacle avoidance
	for i in range(num_rays):
		var raycast: RayCast2D = RayCast2D.new()
		raycast.target_position = Vector2(cos(deg_to_rad(i * (360 / num_rays))), sin(deg_to_rad(i * (360 / num_rays)))) * avoidance_radius
		raycast.enabled = true
		raycasts.append(raycast)
		raycasts_node.add_child(raycast)
	
	# Add a RayCast2D for line of sight
	line_of_sight.enabled = true
	add_child(line_of_sight)

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
func get_repulsion_vector() -> Vector2:
	var repulsion: Vector2 = Vector2.ZERO
	for raycast in raycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			# Get the direction of the colliding raycast
			var raycast_dir: Vector2 = raycast.target_position.normalized()
			# Add a repulsion force in the opposite direction
			repulsion -= raycast_dir
	return repulsion
			
func has_line_of_sight() -> bool:
	line_of_sight.target_position = player.global_position - global_position
	line_of_sight.force_raycast_update()
	return not line_of_sight.is_colliding()

func _physics_process(delta: float) -> void:
	var repulsion: Vector2 = get_repulsion_vector() * repulsion_strenght
	var best_dir: Vector2
	if has_line_of_sight():
		last_known_position = player.global_position
		last_known_velocity = player.velocity.normalized()
		best_dir = get_best_direction() + last_known_velocity
	else:
		if global_position.distance_to(last_known_position) > 5:
			best_dir = get_best_direction()+last_known_velocity
		else:
			best_dir = Vector2.ZERO
			
	velocity = (best_dir+repulsion).normalized() * move_speed
	move_and_slide()
