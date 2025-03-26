extends CharacterBody2D
class_name barrelGoblin

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var state_chart: StateChart = $StateChart
@onready var distance: Vector2 = player.global_position - global_position
#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int



func _physics_process(delta: float) -> void:
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

# IDLE STATE
func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play("idle")
	
func _on_idle_state_processing(delta: float) -> void:
	if player.velocity.length() == 0 and distance.length() < alert_range:
		state_chart.send_event('start following')
	if distance.length() < attack_range:
		state_chart.send_event('start ticking')


# FOLLOW STATE
func _on_follow_state_entered() -> void:
	animation_player.play("move")

func _on_follow_state_processing(delta: float) -> void:
	velocity = (distance.normalized()+player.velocity.normalized()) * move_speed
	if distance.length() > leave_alert_range or player.velocity.length() > 0:
		state_chart.send_event('stop following')
	elif distance.length() < attack_range:
		state_chart.send_event('start ticking')

# STATE TICK
func _on_tick_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play('attack')
	await get_tree().create_timer(2.6).timeout
	queue_free()
