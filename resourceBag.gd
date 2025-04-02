extends Area2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var bag: Area2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var game_manager : Node

func _ready() -> void:
	game_manager =  $"../../GameManager"
	animated_sprite_2d.play("spawn")
	bag.get_node('AudioStreamPlayer2D').playing = true

func _on_body_entered(body: Node2D) -> void:
	if !player.is_carrying:
		player.is_carrying = true 
		game_manager.spawn_bag()
		queue_free()
		
func _process(delta: float) -> void:
	if !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("default")
