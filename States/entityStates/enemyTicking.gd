extends State
class_name enemyTicking

@export var enemy: CharacterBody2D

var animation_player: AnimationPlayer

func Enter() -> void:
	enemy.velocity = Vector2.ZERO
	animation_player = enemy.get_node('AnimationPlayer')
	animation_player.play('attack')
	await get_tree().create_timer(2.6).timeout
	enemy.queue_free()
	
