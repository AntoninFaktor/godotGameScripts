extends CharacterBody2D
class_name Goblin

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_component: hitboxComponent = $hitboxComponent
@onready var hitbox: Area2D = $hitbox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
var is_dead: bool = false

#enemy stats
@export var dmg: int
@export var move_speed: int
@export var attack_range: int
@export var alert_range: int
@export var leave_alert_range: int


func _physics_process(delta: float) -> void:
	move_and_slide()
	if is_dead:
		queue_free()
		
func _on_enemy_attack_is_attacking(attack_direction:String, direction: Vector2) -> void:
	if attack_direction == 'attack_horizontal' and direction.x < 0:
		sprite_2d.flip_h = true
		hitbox.scale.x = -1
	elif attack_direction == 'attack_horizontal' and direction.x > 0:
		sprite_2d.flip_h = false
		hitbox.scale.x = 1
	
	$AudioStreamPlayer2D.pitch_scale=randf_range(.9, 1.1)
	animation_player.play(attack_direction)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)
