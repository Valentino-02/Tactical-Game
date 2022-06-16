extends Node2D


onready var map : TileMap = $Map
onready var move : TileMap = $Move
onready var attack: TileMap = $Attack
onready var select : TileMap = $Select
onready var avatar_holder = $AvatarHolder

var tile_hovered setget set_tile_hovered

var _avatar_unit = preload("res://src//battle/scenes/AvatarUnit.tscn")
var _owner = get_parent()

func draw_map(size: Vector2) -> void:
	for x in size.x:
		for y in size.y:
			map.set_cell(x, y, 0)

func draw_move(tiles: Array):
	if tiles.empty():
		move.clear()
	else:
		for tile in tiles:
			move.set_cellv(tile, 0)

func draw_attack(tiles: Array):
	if tiles.empty():
		attack.clear()
	else: 
		for tile in tiles:
			attack.set_cellv(tile, 0)

func set_tile_hovered(value):
	if tile_hovered != value and tile_hovered != null:
		if !owner.is_mouse_on_map and value in map.get_used_cells():
			owner.is_mouse_on_map = true
		if owner.is_mouse_on_map and not value in map.get_used_cells():
			owner.is_mouse_on_map = false
			select.set_cellv(tile_hovered, -1)
		if owner.is_mouse_on_map:
			select.set_cellv(tile_hovered, -1)
			select.set_cellv(value, 0)
	tile_hovered = value

func _on_unit_added(unit):
	var avatar_unit = _avatar_unit.instance()
	avatar_unit.name = str(unit.pos)
	avatar_unit.player_id = unit._player_id
	avatar_holder.add_child(avatar_unit)
	var offset = map.get_cell_size()/2
	avatar_unit.position = map.map_to_world(unit.pos) + offset

func _on_unit_moved(from, to):
	var avatar = avatar_holder.get_node(str(from))
	avatar.position += map.map_to_world(to - from)
	avatar.name = str(to)

func _on_unit_died(unit):
	var dead_avatar = avatar_holder.get_node(str(unit.pos))
	avatar_holder.remove_child(dead_avatar)
	dead_avatar.queue_free()

func _on_unit_has_acted(has, unit):
	print("oi")
	var avatar = avatar_holder.get_node(str(unit.pos))
	avatar.has_acted = has
