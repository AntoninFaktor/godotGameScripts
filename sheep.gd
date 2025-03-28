extends CharacterBody2D

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
	
	#slow down while closer to target
	#e = player.global_position - global_position
	#var distance = e.length_squared()
	#var steer
	#var ARadius = 80
	#if distance > 0:
		#e = e.normalized()
		#if distance < ARadius* ARadius:
			#e *= move_speed * (sqrt(distance) / ARadius)
		#else:
			#e *= move_speed
		#steer = e - velocity
	#velocity = velocity.lerp(steer, 0.5)
		
#func wander():
	## Wander behavior
	#var direction = velocity.normalized()
	#var center = global_position + direction * 10 # 'length' could be the distance you want to maintain from the target
	#var wdelta = randf_range(-PI, PI)  # Initialize wander delta (you might want to define this outside if it needs to persist across frames)
	#var Rrad = 70  # Random radius for the wandering (set this to control the wandering range)
	#var Vrad = 50  # The velocity radius (how far it wanders from the center)
	#var steer
#
## Random walk - update the wander angle
	#wdelta += randf_range(-Rrad, Rrad)  # Use randf_range to get a random float between -Rrad and Rrad
#
## Calculate the new position using the wander offset
	#var x = Vrad * cos(wdelta)
	#var y = Vrad * sin(wdelta)
	#var offset = Vector2(x, y)
#
## Calculate the target position by adding the offset to the center
	#var target = center + offset
#
## Now seek the new target
	#steer = target
#
## Apply the steering to the velocity (like in previous movement code)
	#velocity = velocity.lerp(steer, 0.1)  # Smooth out the steering

 #Object Avoidance
#func avoid_obstacle(obstacle_position: Vector2, obstacle_radius: float, maxspeed: float) -> Vector2:
	## Calculate the direction to the obstacle
	#var direction_to_obstacle = obstacle_position - global_position
	#var distance_to_obstacle = direction_to_obstacle.length()  # Distance between the object and the obstacle
	#
	## Define the distance threshold
	#var Lb = 100  # Distance threshold (can be adjusted)
	#var rb = 50   # Radius of the object
	#var ro = obstacle_radius  # Radius of the obstacle
	#
	## Check if the object is within the avoidance range (both x and y)
	#if abs(direction_to_obstacle.x) <= Lb and abs(direction_to_obstacle.y) <= (rb + ro):
		## Calculate the avoidance direction and force
		#var n = -direction_to_obstacle.normalized()  # The direction to move away from the obstacle
		#var e = ((rb + ro) - distance_to_obstacle) / (rb + ro)  # Avoidance force factor
		#
		## Scale the avoidance force based on the distance
		#e *= maxspeed
		#
		## Calculate the steering force
		#var steer = e * n
		#
		#return steer
	#else:
		#return Vector2.ZERO  # No need to avoid if the obstacle is far enough away
