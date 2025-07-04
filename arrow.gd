extends CharacterBody2D
class_name Arrow

@export var dmg: int
@export var move_speed:int
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var sprite: Sprite2D = $Sprite2D
var target : Vector2
var direction: Vector2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var hitbox_component: hitboxComponent = $hitboxComponent


func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is hitboxComponent:
		var hitbox: hitboxComponent = area
		var attack = Attack.new()
		attack.attack_dmg = dmg
		hitbox.take_dmg(attack)
		direction = Vector2.ZERO
		hitbox_component.queue_free()
		sprite.frame = 1
		audio_stream_player_2d.pitch_scale=randf_range(.9, 1.1)
		audio_stream_player_2d.play(.1)

func arrow_flight(start_position: Vector2, target_position: Vector2):
	global_position = start_position
	direction = (target_position - start_position).normalized()

func _process(delta: float) -> void:
	global_position += direction * move_speed * delta

func _on_timer_timeout() -> void:
	queue_free()
