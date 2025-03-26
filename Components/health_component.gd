extends Node
class_name healthComponent

@export var player: CharacterBody2D
signal current_health(health:int)

@export var health: int:
	set(value):
		health = clamp(value, 0, 3)

func take_damage(attack: Attack) -> void:
	health -= attack.attack_dmg
	if health == 0:
		get_parent().is_dead = true

func _process(delta: float) -> void:
	current_health.emit(health)
