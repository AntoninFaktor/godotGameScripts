extends CharacterBody2D
class_name EntityTamplate

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Components/hitbox
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
var best_dir_args: Array
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

func _process(delta: float) -> void:
	best_dir_args = [last_known_position, num_dir, repulsion_strenght, avoidance_radius, goal_weight, avoidance_weight]

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
	elif distance.length() < alert_range:
		next_state = States.FOLLOW
	elif distance.length() > leave_alert_range:
		next_state = States.WANDER
#endregion
