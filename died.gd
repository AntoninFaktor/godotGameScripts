extends Node2D

@export var enemy: CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func entity_died() -> void:
	for node in enemy.get_children():
		if node == Sprite2D and node.visible:
			Sprite2D.visible = false
	animation_player.play("EntityDied")
	if !animation_player.is_playing():
		queue_free()
