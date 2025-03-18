extends Node

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ran_num: float = randf_range(.9,1.1)
	self.scale = self.scale*ran_num
	if ran_num*randf_range(-1,1) > 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
