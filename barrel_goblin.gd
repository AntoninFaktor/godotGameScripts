extends CharacterBody2D

class_name barrelGoblin

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var state_chart: StateChart = $StateChart
@onready var distance: Vector2
@onready var last_known_position: Vector2 = player.global_position
@onready var line_of_sight: RayCast2D = RayCast2D.new()
@onready var pathfinder: PathfinderComponent = $Components/PathfinderComponent
#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int

var is_dead: bool = false

@export var avoidance_radius: int
@export var goal_weight: float = 10.0
@export var avoidance_weight: float = 20.0
@export var repulsion_strenght: float = .75
var num_dir: int = 18
var best_dir_args: Array
var last_known_velocity: Vector2 = Vector2.ZERO

enum States {IDLE, FOLLOW, TICK}
@export var curr_state : States
var next_state: States

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack: Attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)

func _ready() -> void:
	distance = player.global_position - global_position
	pathfinder.initialize_raycasts(num_dir, avoidance_radius)
	# Add a RayCast2D for line of sight
	line_of_sight.enabled = true
	add_child(line_of_sight)

func _process(delta: float) -> void:
	best_dir_args = [last_known_position, num_dir, repulsion_strenght, avoidance_radius, goal_weight, avoidance_weight]

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
			
func get_next_state() -> void:
	if player.is_dead:
		next_state = States.IDLE
	elif curr_state == States.TICK:
		next_state = curr_state
	elif is_dead:
		next_state = States.TICK
		$"../../GameManager".add_score()
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
func _on_follow_state_entered() -> void:
	animation_player.play('move')

func _on_follow_state_processing(delta: float) -> void:
	var best_dir: Vector2
	if has_line_of_sight():
		last_known_velocity = player.velocity
		last_known_position = player.global_position+last_known_velocity
	if not has_line_of_sight():
		best_dir = pathfinder.callv('get_best_direction', best_dir_args)
	else:
		if player.velocity == Vector2.ZERO:
			best_dir = pathfinder.callv('get_best_direction', best_dir_args)
		else:
				best_dir = last_known_position-global_position
				next_state = States.IDLE
	var desired_velocity = (best_dir).normalized() * move_speed
	velocity = velocity.lerp(desired_velocity, .33)
#endregion

#region TICK STATE
func clear_on_dead() -> void:
	queue_free()
func _on_tick_state_entered() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animation_player.play('attack')
#endregion
