extends Node

class_name PathfinderComponent

@export var entity: CharacterBody2D
var raycast_update_timer: int = 0
var directions: Array = []
var raycasts: Array = []

const RAYCAST_UPDATE_INTERVAL: int = 5
const DIRECTION_BLOCK_THRESHOLD: float = 0.8
const DISTANCE_PENALTY_FACTOR: float = 0.1
const GOAL_ATTRACTION_FACTOR: float = 0.5

func initialize_raycasts(num_rays:int, avoidance_radius) -> void:
		# Initialize raycasts for obstacle avoidance
	for i:int in range(num_rays):
		var raycast: RayCast2D = RayCast2D.new()
		raycast.target_position = Vector2(cos(deg_to_rad(i * (360 / num_rays))), sin(deg_to_rad(i * (360 / num_rays)))) * avoidance_radius
		raycast.enabled = true
		raycasts.append(raycast)
		entity.add_child(raycast)

func update_raycast_collisions() -> void:
	for raycast:RayCast2D in raycasts:
		raycast.force_raycast_update()

func calculate_goal_attraction(target_vector: Vector2, direction: Vector2)-> float:
	return target_vector.dot(direction)

func calculate_obstacle_penalty(direction: Vector2) -> int:
	if is_direction_blocked(direction):
		return 1 
	else:
		return 0

func calculate_distance_penalty(entity_position: Vector2, direction: Vector2, target_position: Vector2, avoidance_radius: int) -> float:
	var distance_to_goal: float = (entity_position + direction).distance_to(target_position) * DISTANCE_PENALTY_FACTOR
	return avoidance_radius * 0.1 / distance_to_goal

func get_repulsion_vector(repulsion_strenght:float) -> Vector2:
	var blocked_directions: Array = []
	var repulsion: Vector2 = Vector2.ZERO
	var repulsion_dir: Vector2 = Vector2.ZERO
	for raycast in raycasts:
		if raycast.is_colliding():
			# Get the direction of the colliding raycast
			var raycast_dir: Vector2 = raycast.target_position
			# Add a repulsion force in the opposite direction
			repulsion -= raycast_dir
			blocked_directions.append(repulsion)
			
	for rep_dir in blocked_directions:
		repulsion_dir += rep_dir

	repulsion_dir = repulsion_dir.normalized() * repulsion_strenght
	return repulsion_dir

func generate_directions(num_dir:int) -> void:
	directions.clear()
	#Generate possible directions for movement
	for i:int in range(num_dir):
		var angle:float = deg_to_rad(i * 360 / num_dir)
		directions.append(Vector2(cos(angle), sin(angle)))

func is_direction_blocked(direction: Vector2) -> bool:
	for raycast:RayCast2D in raycasts:
		if raycast.is_colliding():
			var raycast_dir = raycast.target_position.normalized()
			if raycast_dir.dot(direction) > DIRECTION_BLOCK_THRESHOLD:
				return true
	return false

func get_best_direction(target_position: Vector2, num_dir:int, repulsion_strenght:float, avoidance_radius:int, goal_weight:float, avoidance_weight: float):
	if directions.size() != num_dir:
		generate_directions(num_dir)
	var target_vector: Vector2 = (target_position - entity.global_position).normalized()
	var best_direction: Vector2 = Vector2.ZERO
	var best_score: float = -float("inf")
	raycast_update_timer +=1
	if raycast_update_timer > RAYCAST_UPDATE_INTERVAL:
		update_raycast_collisions()
		raycast_update_timer = 0
	var repulsion_vector: Vector2 = get_repulsion_vector(repulsion_strenght)
	for dir in directions:
		var dir_normalized: Vector2 = dir.normalized()
		var goal_attraction: float = calculate_goal_attraction(target_vector, dir_normalized)
		var obstacle_penalty: int = calculate_obstacle_penalty(dir_normalized)
		var distance_penalty: float = calculate_distance_penalty(entity.global_position, dir, target_position, avoidance_radius)
		if goal_attraction > 0:
			distance_penalty *= DISTANCE_PENALTY_FACTOR
		var score: float = (goal_weight * goal_attraction) - (avoidance_weight * obstacle_penalty) - distance_penalty
		if score > best_score:
			best_direction = dir
			best_score = score

	return best_direction + repulsion_vector
