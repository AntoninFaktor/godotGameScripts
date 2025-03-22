extends CharacterBody2D
class_name barrelGoblin

@export var dmg: int
@export var move_speed: int
@export var range: int
@export var enter_vacinity_range: int
@export var exit_vacinity_range: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')

func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta)


func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)
