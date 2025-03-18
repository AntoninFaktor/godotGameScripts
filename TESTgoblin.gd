extends CharacterBody2D
class_name Goblin

@export var dmg: int = 1
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	move_and_slide()
	if velocity.length() > 0:
		animation_player.play("move")
		
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$hitbox.scale.x = 1
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$hitbox.scale.x = -1

func _on_enemy_attack_is_attacking(attack_direction) -> void:
	animation_player.play(attack_direction)



func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)
