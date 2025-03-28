extends Area2D

@onready var grass_layer: TileMapLayer = $"../GrassLayer"
@onready var tiles = grass_layer.get_used_cells_by_id()
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var bag: Area2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func new_spawn() -> void:
	bag.global_position = tiles[ randi() % tiles.size() ] * grass_layer.tile_set.tile_size
	animated_sprite_2d.play("spawn")

func _on_body_entered(body: Node2D) -> void:
	if !player.is_carrying:
		player.is_carrying = true
		new_spawn()
		while bag.get_overlapping_areas():
			new_spawn()
		bag.get_node('AudioStreamPlayer2D').playing = true
		
func _process(delta: float) -> void:
	if !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("default")
