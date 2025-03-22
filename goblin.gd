extends CharacterBody2D
class_name Goblin2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_component: hitboxComponent = $hitboxComponent
@onready var hitbox: Area2D = $hitbox
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
var is_dead: bool = false
var direction: Vector2
var wander_time: float
var distance: Vector2

#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int


func _physics_process(delta: float) -> void:
	move_and_slide()
	distance = player.global_position - global_position
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
	if is_dead:
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack:Attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)

# IDLE STATE
func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO
	animation_player.play("idle")

func _on_idle_state_processing(delta: float) -> void:
	if distance.length() < alert_range and !player.is_dead:
		$"StateChart/GoblinStates/Idle/To Follow".take()

# WANDER STATE
var i: int = 0
func randomize_wander() -> void:
	direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1, 3)

func _on_wander_state_entered() -> void:
	animation_player.play("move")
	randomize_wander()
	
func _on_wander_state_processing(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	elif i > 3:
		$"StateChart/GoblinStates/Wander/To Idle".take()
		i = 0
	else:
		i += 1	
		randomize_wander()
	
func _on_wander_state_physics_processing(delta: float) -> void:
	if is_on_ceiling() || is_on_floor() || is_on_wall():
		direction = direction * -1
	velocity = direction * (move_speed * .6)
	if distance.length() < alert_range:
		$"StateChart/GoblinStates/Wander/To Follow".take()
		
# FOLLOW STATE
func _on_follow_state_entered() -> void:
	animation_player.play("move")


func _on_follow_state_processing(delta: float) -> void:
	velocity = distance.normalized() * move_speed
	if distance.length() > leave_alert_range:
		$"StateChart/GoblinStates/Follow/To Wander".take()
	elif distance.length() < attack_range:
		$"StateChart/GoblinStates/Follow/To Attack".take()
		
# ATTACK STATE
func _on_attack_state_entered() -> void:
	velocity = Vector2.ZERO
	await get_tree().create_timer(.16).timeout
	$hitbox/CollisionShape2D.disabled = false

func _on_attack_state_processing(delta: float) -> void:
	if distance.length() > attack_range:
		$"StateChart/GoblinStates/Attack/To Follow".take()
	if player.is_dead:
		$"StateChart/GoblinStates/Attack/To Idle".take()

func _on_attack_state_physics_processing(delta: float) -> void:
	$AudioStreamPlayer2D.pitch_scale=randf_range(.9, 1.1)
	if distance.x < 0:
		sprite.flip_h = true
		hitbox.scale.x = -1
	elif distance.x < 0:
		sprite.flip_h = false
		hitbox.scale.x = 1
	if abs(distance.x) > abs(distance.y):
		animation_player.play('attack_horizontal')
	elif distance.y < 0:
		animation_player.play('attack_up')
	elif distance.y > 0:
		animation_player.play('attack_down')

func _on_attack_state_exited() -> void:
	$hitbox/CollisionShape2D.disabled = true
