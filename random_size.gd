extends Node

#Ranmdomize scale as well as flipping the sprite
func _ready() -> void:
	var ran_num: float = randf_range(.9,1.1)
	self.scale = self.scale*ran_num
	if ran_num*randi_range(-1,1) > 0:
		self.scale.x = 1
	else:
		self.scale.x = -1
