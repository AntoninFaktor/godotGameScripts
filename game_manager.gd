extends Node

@onready var label: Label = $"../CanvasLayer/PanelContainer2/MarginContainer/GridContainer/Label"

var score: int = 0
var goblins: Node2D
var goblin = preload('res://scenes/goblin.tscn')
var barrel_goblin = preload('res://scenes/barrel_goblin.tscn')
@onready var grass_layer: TileMapLayer = $"../GrassLayer"
@onready var tiles = grass_layer.get_used_cells_by_id()

func spawn(enemy: Node) -> void:
	var instance = enemy.instantiate()
	goblins.call_deferred('add_child',instance)
	instance.global_position = tiles[ randi() % tiles.size() ] * grass_layer.tile_set.tile_size

func _ready() -> void:
	goblins = $"../goblins"
	label.text = str(score)
	
func add_point():
	score +=1
	if score % 2==0:
		spawn(barrel_goblin)
	label.text = str(score)

func _on_timer_timeout() -> void:
	spawn(goblin)
