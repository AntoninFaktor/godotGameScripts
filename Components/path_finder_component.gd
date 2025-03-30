extends Node

class_name PathfinderComponent

@export var entity: CharacterBody2D
var directions: Array = []
var raycasts: Array = []

func initialize_raycasts(num_rays:int, avoidance_radius) -> void:
		# Initialize raycasts for obstacle avoidance
	for i in range(num_rays):
		var raycast: RayCast2D = RayCast2D.new()
		raycast.target_position = Vector2(cos(deg_to_rad(i * (360 / num_rays))), sin(deg_to_rad(i * (360 / num_rays)))) * avoidance_radius
		raycast.enabled = true
		raycasts.append(raycast)
		entity.add_child(raycast)
		
func get_repulsion_vector(repulsion_strenght:float) -> Vector2:
	var blocked_directions: Array = []
	var repulsion: Vector2 = Vector2.ZERO
	var repulsion_dir: Vector2 = Vector2.ZERO
	for raycast in raycasts:
		raycast.force_raycast_update()
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
	for i in range(num_dir):
		var angle = deg_to_rad(i * 360 / num_dir)
		directions.append(Vector2(cos(angle), sin(angle)))

func is_direction_blocked(direction: Vector2) -> bool:
	for raycast in raycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var raycast_dir = raycast.target_position.normalized()
			if raycast_dir.dot(direction.normalized()) > 0.8:
				return true
	return false

func get_best_direction(target_position: Vector2, num_dir:int, repulsion_strenght:float, avoidance_radius:int, goal_weight:float, avoidance_weight: float):
	generate_directions(num_dir)
	var target_vector: Vector2 = target_position - entity.global_position
	var best_direction: Vector2 = Vector2.ZERO
	var best_score: float = -float("inf")
	var repulsion_vector: Vector2 = get_repulsion_vector(repulsion_strenght)
	for dir in directions:
		var dir_normalized: Vector2 = dir.normalized()
		var goal_attraction: float = target_vector.normalized().dot(dir_normalized)
		var obstacle_penalty: int = 0
		if is_direction_blocked(dir):
			obstacle_penalty = 1
		var distance_to_goal: float = (entity.global_position + dir).distance_to(target_position)*.1
		var distance_penalty: float = avoidance_radius*.1 / distance_to_goal
		if goal_attraction > 0:
			distance_penalty *= 0.5
		var score: float = (goal_weight * goal_attraction) - (avoidance_weight * obstacle_penalty) - distance_penalty
		if score > best_score:
			best_direction = dir
			best_score = score

	return best_direction + repulsion_vector
