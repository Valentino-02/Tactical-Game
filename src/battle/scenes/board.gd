extends Node2D


onready var map : TileMap = $Map
onready var move : TileMap = $Move
onready var attack: TileMap = $Attack
onready var hover : TileMap = $Hover
onready var deploy : TileMap = $Deploy
onready var avatar_holder = $AvatarHolder

var tile_hovered setget set_tile_hovered

var _avatar_unit = preload("res://src//battle/scenes/AvatarUnit.tscn")
var _avatar_structure = preload("res://src//battle/scenes/AvatarStructure.tscn")
var _owner = get_parent()

func draw_map(size: Vector2) -> void:
	for x in size.x:
		for y in size.y:
			map.set_cell(x, y, 0)

func draw_gold_mine(mine: GoldMine) -> void:
	if mine.owner_id == 0:
		for pos in mine._positions:
			map.set_cellv(pos, 1)
	if mine.owner_id == 1:
		for pos in mine._positions:
			map.set_cellv(pos, 2)
	if mine.owner_id == 2:
		for pos in mine._positions:
			map.set_cellv(pos, 3)

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

func draw_deploy(tiles: Array):
	if tiles.empty():
		deploy.clear()
	else: 
		for tile in tiles:
			deploy.set_cellv(tile, 0)

func set_tile_hovered(value):
	if tile_hovered != value and tile_hovered != null:
		if !owner.is_mouse_on_map and value in map.get_used_cells():
			owner.is_mouse_on_map = true
		if owner.is_mouse_on_map and not value in map.get_used_cells():
			owner.is_mouse_on_map = false
			hover.set_cellv(tile_hovered, -1)
		if owner.is_mouse_on_map:
			hover.set_cellv(tile_hovered, -1)
			hover.set_cellv(value, 0)
	tile_hovered = value

func _on_entity_added(entity):
	var avatar 
	if entity._type == "unit":
		avatar = _avatar_unit.instance()
	if entity._type == "structure":
		avatar = _avatar_structure.instance()
	avatar.player_id = entity._player_id
	avatar.name = str(entity.pos)
	avatar_holder.add_child(avatar)
	var offset = map.get_cell_size()/2
	avatar.position = map.map_to_world(entity.pos) + offset

func _on_unit_moved(from, to):
	var avatar = avatar_holder.get_node(str(from))
	avatar.position += map.map_to_world(to - from)
	avatar.name = str(to)

func _on_entity_died(entity):
	var avatar = avatar_holder.get_node(str(entity.pos))
	avatar_holder.remove_child(avatar)
	avatar.queue_free()

func _on_unit_has_acted(has, unit):
	var avatar = avatar_holder.get_node(str(unit.pos))
	avatar.has_acted = has

func _on_gold_mine_owner_changed(mine):
	draw_gold_mine(mine)
