extends Node

@onready var label: Label = $"../CanvasLayer/PanelContainer2/MarginContainer/GridContainer/Label"

var score = 0

func _ready() -> void:
	label.text = str(score)

func add_point():
	score +=1
	label.text = str(score)
