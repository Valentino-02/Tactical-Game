extends Node2D


onready var map : TileMap = $Map
onready var interact : TileMap = $Interact
onready var select : TileMap = $Select
onready var board_holder = $BoardHolder

var tile_pos setget set_tile_pos

var _owner = get_parent()

func draw_map(size: Vector2) -> void:
	for x in size.x:
		for y in size.y:
			map.set_cell(x, y, 0)

func set_tile_pos(value):
	if tile_pos != value:
		if !owner.is_mouse_on_map and value in map.get_used_cells():
			owner.is_mouse_on_map = true
		if owner.is_mouse_on_map and not value in map.get_used_cells():
			owner.is_mouse_on_map = false
			select.set_cellv(tile_pos, -1)
		if owner.is_mouse_on_map:
			select.set_cellv(tile_pos, -1)
			select.set_cellv(value, 0)
	tile_pos = value

func add_entity(entity, pos):
	board_holder.add_child(entity)
	var offset = map.get_cell_size()/2
	entity.position = map.map_to_world(pos) + offset
	
