extends Node

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ran_num: float = randf_range(.9,1.1)
	self.scale = self.scale*ran_num
	if ran_num*randi_range(-1,1) > 0:
		self.scale.x = 1
	else:
		self.scale.x = -1
