extends Sprite2D

@onready var player: CharacterBody2D = $".."


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.is_carrying:
		self.visible = true
	else:
		self.visible = false
