extends StaticBody2D

class_name Castle

var player: CharacterBody2D
@onready var game_manager: Node = %GameManager
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')

#Bag deliver func
func _on_area_2d_body_entered(body: Node2D) -> void:
	if player.is_carrying:
		audio_stream_player_2d.playing = true
		game_manager.add_point()
		player.is_carrying = false
