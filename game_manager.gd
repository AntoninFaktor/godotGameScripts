extends Node

@onready var label: Label = $"../CanvasLayer/PanelContainer2/MarginContainer/GridContainer/Label"
@onready var grass_layer: TileMapLayer = $"../GrassLayer"
@onready var tiles: Array = []
@onready var valid_tiles: Array = []

var score: int = 0
var goblins: Node2D
var goblin = preload('res://scenes/goblin.tscn')
var barrel_goblin = preload('res://scenes/barrel_goblin.tscn')
var rng = RandomNumberGenerator.new()

const TILE_MARGIN = 1

func _ready() -> void:
	goblins = $"../goblins"
	label.text = str(score)
	tiles = grass_layer.get_used_cells_by_id()
	valid_tiles = filter_valid_tiles(tiles)

func filter_valid_tiles(used_tiles: Array) -> Array:
	var valid_tiles = []
	var tile_size = grass_layer.tile_set.tile_size
	var map_size = grass_layer.get_used_rect()
	for tile in used_tiles:
		var world_pos = tile * tile_size
		if world_pos.x > TILE_MARGIN * tile_size.x and world_pos.x < (map_size.size.x - TILE_MARGIN) * tile_size.x and world_pos.y > TILE_MARGIN * tile_size.y and world_pos.y < (map_size.size.y - TILE_MARGIN) * tile_size.y:
			valid_tiles.append(tile)
	return valid_tiles

func spawn(enemy) -> void:
	if valid_tiles.is_empty():
		print("No valid tiles available for spawning!")
		return
	var instance = enemy.instantiate()
	goblins.call_deferred('add_child', instance)
	instance.global_position = valid_tiles[rng.randi_range(0, valid_tiles.size() - 1)] * grass_layer.tile_set.tile_size

func add_point():
	score += 1
	label.text = str(score)
	if score % 2 == 0:
		spawn(barrel_goblin)

func _on_timer_timeout() -> void:
	spawn(goblin)
