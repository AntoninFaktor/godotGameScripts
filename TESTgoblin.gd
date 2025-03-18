extends CharacterBody2D
class_name Goblin

@export var dmg: int = 1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_component: hitboxComponent = $hitboxComponent
@onready var animated_sprite_2d: Sprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	move_and_slide()
	if velocity.length() > 0:
		animation_player.play("move")
		
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

func _on_enemy_attack_is_attacking(attack_direction) -> void:
	animation_player.play(attack_direction)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)
