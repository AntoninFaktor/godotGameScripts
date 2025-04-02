extends Node

class_name GameManager

@onready var kills: Label = $"../CanvasLayer/PanelContainer2/MarginContainer/GridContainer/Label2"
@onready var collected_gold: Label = $"../CanvasLayer/PanelContainer2/MarginContainer/GridContainer/Label"
@onready var grass_layer: TileMapLayer = $"../GrassLayer"
@onready var tiles: Array = []
@onready var valid_tiles: Array = []
@onready var bag_spawn: Timer = $BagSpawn

var gold: float = 0
var since_last_bag: float
var overall_collected: int = 0
var score: int = 0
var goblins: Node2D
var goblin = preload('res://scenes/goblin.tscn')
var barrel_goblin = preload('res://scenes/barrel_goblin.tscn')
var resource_bag = preload("res://scenes/bag.tscn")
var rng = RandomNumberGenerator.new()

const TILE_MARGIN = 1

func _ready() -> void:
	goblins = $"../goblins"
	kills.text = str(score)
	collected_gold.text = str(gold)
	tiles = grass_layer.get_used_cells_by_id()
	valid_tiles = filter_valid_tiles(tiles)
	spawn_bag()

func filter_valid_tiles(used_tiles: Array) -> Array:
	var valid_tiles = []
	var tile_size = grass_layer.tile_set.tile_size
	var map_size = grass_layer.get_used_rect()
	var min_x = (map_size.position.x + TILE_MARGIN) * tile_size.x
	var max_x = (map_size.position.x + map_size.size.x - TILE_MARGIN) * tile_size.x
	var min_y = (map_size.position.y + TILE_MARGIN) * tile_size.y
	var max_y = (map_size.position.y + map_size.size.y - TILE_MARGIN) * tile_size.y

	for tile in used_tiles:
		var world_pos = tile * tile_size
		if world_pos.x > min_x and world_pos.x < max_x and world_pos.y > min_y and world_pos.y < max_y:
			valid_tiles.append(tile)
	return valid_tiles

func spawn(enemy) -> void:
	if valid_tiles.is_empty():
		print("No valid tiles available for spawning!")
		return
	var instance = enemy.instantiate()
	goblins.call_deferred('add_child', instance)
	instance.global_position = valid_tiles[rng.randi_range(0, valid_tiles.size() - 1)] * grass_layer.tile_set.tile_size

func add_gold():
	gold += (roundf(randf_range(1,2)*10))/10
	overall_collected +=1
	collected_gold.text = str(gold)
	if overall_collected % 2 == 0:
		spawn(barrel_goblin)

func spawn_bag():
	if valid_tiles.is_empty():
		print("No valid tiles available for spawning!")
		return
	var instance = resource_bag.instantiate()
	call_deferred('add_child', instance)
	instance.global_position = valid_tiles[rng.randi_range(0, valid_tiles.size() - 1)] * grass_layer.tile_set.tile_size
	
	bag_spawn.start()

func buy_arrow():
	gold-=1
	collected_gold.text = str(gold)
	
func add_score():
	score += 1
	kills.text = str(score)
	
func _on_timer_timeout() -> void:
	spawn(goblin)

func _on_bag_spawn_timeout() -> void:
	spawn_bag()
	bag_spawn.wait_time += 1
	print(bag_spawn.wait_time)
