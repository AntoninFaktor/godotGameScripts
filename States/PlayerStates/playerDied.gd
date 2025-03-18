extends State
class_name playerDied

@export var player: CharacterBody2D

func Enter() -> void:
	player.velocity = Vector2(0, 0)
	player.animated_sprite.play('dead')
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
