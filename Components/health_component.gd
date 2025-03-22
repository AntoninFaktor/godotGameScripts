extends Node
class_name healthComponent

@export var player: CharacterBody2D
signal current_health(health:int)

@export var health: int:
	set(value):
		health = clamp(value, 0, 3)

func take_damage(attack: Attack) -> void:
	health -= attack.attack_dmg
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_blink_intensity, 1.0, 0.0, 0.5)
	if health == 0:
		get_parent().is_dead = true
	
func set_shader_blink_intensity(newValue: float) -> void:
	player.get_node('pawnSprite').material.set_shader_parameter('blink_intesity', newValue )

func _process(delta: float) -> void:
	current_health.emit(health)
