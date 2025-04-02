extends CharacterBody2D
class_name Archer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var bow: Sprite2D = $Bow
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var enemies: Array = []
var target_enemy
@onready var last_known_position: Vector2
@onready var state_chart: StateChart = $StateChart
@onready var movement_blocked: RayCast2D = RayCast2D.new()
@onready var pathfinder: PathfinderComponent = $Components/PathfinderComponent
var arrow = preload('res://scenes/arrow.tscn')

var is_dead: bool = false
var wander_time: float
var distance: Vector2

@export var avoidance_radius: int
@export var goal_weight: float = 10.0
@export var avoidance_weight: float = 20.0
@export var repulsion_strenght: float = .75
var best_dir_args: Array
var num_dir: int = 12
var last_known_velocity: Vector2 = Vector2.ZERO

#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int

func _ready():
	# Initialize raycasts for obstacle avoidance
	pathfinder.initialize_raycasts(num_dir, avoidance_radius, 3)
	# Add a RayCast2D for line of sight
	movement_blocked.enabled = true
	add_child(movement_blocked)
	update_state()
	
func get_target_enemy() -> CharacterBody2D:
	enemies = $"../goblins".get_children()
	var closest_enemy: CharacterBody2D = null
	var closest_distance: float = INF  # Use a large value to initialize the closest distance

	for enemy: CharacterBody2D in enemies:
		var distance_to_enemy = (enemy.global_position - global_position).length()
		if distance_to_enemy < closest_distance and not enemy.is_dead:
			closest_distance = distance_to_enemy
			closest_enemy = enemy

	target_enemy = closest_enemy
	return target_enemy

func _process(delta: float) -> void:
	best_dir_args = [last_known_position, num_dir, repulsion_strenght, avoidance_radius, goal_weight, avoidance_weight]

func _physics_process(delta: float) -> void:
	distance =get_target_enemy().global_position - global_position
	get_next_state()
	if curr_state != next_state:
		update_state()
	move_and_slide()
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func has_movement_blocked(direction:Vector2) -> bool:
		movement_blocked.target_position =direction.normalized()*15
		movement_blocked.set_collision_mask_value(1, false)
		movement_blocked.set_collision_mask_value(3, true)
		movement_blocked.force_raycast_update()
		return not movement_blocked.is_colliding()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack: Attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)

enum States {IDLE, FOLLOW, ATTACK}
@export var curr_state : States
var next_state: States

#region HANDLE STATES
func update_state() -> void:
	curr_state = next_state
	match curr_state:
		States.IDLE:
			state_chart.send_event('idle')
		States.FOLLOW:
			state_chart.send_event('follow')
		States.ATTACK:
			state_chart.send_event('attack')

			
func get_next_state() -> void:
	if distance.length() < attack_range and %GameManager.gold >= 1:
		next_state = States.ATTACK
	elif distance.length() < alert_range and has_movement_blocked(distance):
		next_state = States.FOLLOW
	else:
		next_state = States.IDLE
#endregion


func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play("Idle")

func _on_follow_state_entered() -> void:
	animation_player.play("Follow")

func _on_follow_state_physics_processing(delta: float) -> void:
	var best_dir: Vector2
	last_known_position =get_target_enemy().global_position
	last_known_velocity =get_target_enemy().velocity.normalized()
	best_dir = pathfinder.callv('get_best_direction', best_dir_args)

	var desired_velocity = (best_dir).normalized() * move_speed
	velocity = velocity.lerp(desired_velocity, .33)

func _on_attack_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play("Attack")
	
func _on_attack_state_physics_processing(delta: float) -> void:
	bow.look_at(target_enemy.position)
	if distance.normalized().x < 0:
		sprite.flip_h = true
	if distance.normalized().x > 0:
		sprite.flip_h = false

func shoot_arrow():
	if target_enemy == null:
		return
	%GameManager.buy_arrow()
	var instance = arrow.instantiate()
	$"../arrows".call_deferred('add_child', instance)
	# Ignore very small velocity components to avoid inaccuracies
	var target_velocity = target_enemy.velocity
	# Predict the target's future position with clamping
	var max_prediction_distance = 200.0
	var predicted_position = target_enemy.global_position + target_velocity*randf_range(.3,.7)
	# Calculate the direction to the predicted position
	var direction = (predicted_position - bow.global_position).normalized()
	# Set the arrow's position and rotation
	instance.global_position = bow.global_position
	instance.rotation = direction.angle()
	# Pass the predicted position to the arrow's flight logic
	instance.call_deferred('arrow_flight', bow.global_position, predicted_position)
