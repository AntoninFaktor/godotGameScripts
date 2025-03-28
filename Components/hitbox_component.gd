extends Area2D
class_name hitboxComponent
@export var health_component: healthComponent

func take_dmg (attack: Attack) -> void:
	print('taking dmg')
	if health_component:
		health_component.take_damage(attack)
