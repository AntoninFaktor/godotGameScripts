extends Sprite2D


@onready var player: CharacterBody2D = $".."

func _process(delta: float) -> void:
	if player.is_dead:
		self.visible = true
