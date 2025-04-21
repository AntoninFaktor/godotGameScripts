extends Node
class_name healthComponent

@export var entity: CharacterBody2D
signal current_health(health:int)
signal damage_taken()

@export var health: int:
	set(value):
		health = clamp(value, 0, 3)

func take_damage(attack: Attack) -> void:
	health -= attack.attack_dmg
	if health > 0:
		damage_taken.emit()
	if health <= 0:
		entity.is_dead = true

func _process(delta: float) -> void:
	current_health.emit(health)
