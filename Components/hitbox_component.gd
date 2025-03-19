extends Area2D
class_name hitboxComponent
@export var health_component: healthComponent

func take_dmg (attack: Attack) -> void:
	if health_component:
		health_component.take_damage(attack)
