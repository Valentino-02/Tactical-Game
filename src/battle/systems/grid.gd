extends Resource
class_name Grid


var grid := {}

var _cell_info := {
	"id": "",
	"ocupied": false,
	"unit" : null,
	"structure" : null,
}


func create_empty_grid(x_tiles: int, y_tiles: int) -> void:
	for x in range(0, x_tiles, 1):
		for y in range(0, y_tiles, 1):
			grid[str(x) + "," + str(y)] = _cell_info.duplicate()
			grid[str(x) + "," + str(y)].id = str(x) + "," + str(y)

func is_in_grid(pos: Vector2) -> bool:
	return grid.has(_str(pos))

func is_ocupied(pos: Vector2) -> bool:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	return grid[_str(pos)].ocupied

func has_unit(pos: Vector2) -> bool:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	return true if grid[_str(pos)].unit else false

func has_enemy(pos: Vector2, player_id) -> bool:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	if grid[_str(pos)].unit:
		if get_unit(pos)._player_id != player_id:
			return true
		else: return false
	else: return false

func has_ally(pos: Vector2, player_id) -> bool:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	if grid[_str(pos)].unit:
		if get_unit(pos)._player_id == player_id:
			return true
		else: return false
	else: return false


func add_unit(unit, pos: Vector2) -> void:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	assert(!is_ocupied(pos), "%s is ocupied" %pos)
	grid[_str(pos)].unit = unit
	grid[_str(pos)].ocupied = true

func remove_unit(pos: Vector2) -> void:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	assert(has_unit(pos), "%s doesnt have a unit" %pos)
	grid[_str(pos)].unit = null
	grid[_str(pos)].ocupied = false

func get_unit(pos: Vector2) -> Unit:
	assert(is_in_grid(pos), "%s is not part of the grid" %pos)
	assert(has_unit(pos), "%s doesnt have a unit" %pos)
	return grid[_str(pos)].unit

func move_unit(from: Vector2, to: Vector2) -> void:
	assert(is_in_grid(from) or is_in_grid(to), "%s or %s is not part of the grid" %[from, to])
	assert(has_unit(from), "%s doesnt have a unit" %from)
	assert(!is_ocupied(to), "%s is ocupied" %to)
	var unit = grid[_str(from)].unit
	grid[_str(from)].unit = null
	grid[_str(from)].ocupied = false
	grid[_str(to)].unit = unit
	grid[_str(to)].ocupied = true

func get_distance(pos1: Vector2, pos2: Vector2) -> int:
	var x = abs(pos1.x - pos2.x)
	var y = abs(pos1.y - pos2.y)
	return x + y

func is_zone_control(pos: Vector2, player_id) -> bool:
	var is_zone = false
	var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	for n in neighbors:
		if !is_in_grid(pos + n): continue
		if !has_unit(pos + n): continue
		var unit = get_unit(pos +n)
		if unit._player_id != player_id:
			is_zone = true
			break
	return is_zone

func get_tiles_in_range(start_pos: Vector2, R: int) -> Array:
	assert(is_in_grid(start_pos), "%s is not part of the grid" %start_pos)
	assert(R > 0, "radius should be positive")
	var out = []
	_append(out, start_pos + Vector2(R,0))
	_append(out, start_pos + Vector2(-R,0))
	_append(out, start_pos + Vector2(0,R))
	_append(out, start_pos + Vector2(0,-R))
	for x in range (1, R, 1):
		var y = R - x 
		_append(out, start_pos + Vector2(x,y))
		_append(out, start_pos + Vector2(-x,y))
		_append(out, start_pos + Vector2(x,-y))
		_append(out, start_pos + Vector2(-x,-y))
	return out

func get_tiles_in_ranges(start_pos: Vector2, min_range: int, max_range: int) -> Array:
	assert(max_range >= min_range, "min_range is bigger than than max_range")
	var out = []
	for R in range(min_range, max_range + 1, 1):
		out.append_array(get_tiles_in_range(start_pos, R))
	return out

func get_attackable_tiles(start_pos: Vector2, min_range: int, max_range: int) -> Array:
	var out = []
	var player_id = get_unit(start_pos)._player_id
	var tiles_to_test = get_tiles_in_ranges(start_pos, min_range, max_range)
	for tile in tiles_to_test:
		if has_unit(tile): 
			var unit = get_unit(tile)
			if unit._player_id == player_id: continue
		out.append(tile)
	return out

func get_walkable_tiles(start_pos: Vector2, max_steps: int) -> Array:
	var out = []
	var owner_id = get_unit(start_pos)._player_id
	var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	var steps = 0
	var checked = [start_pos]
	var queue = [start_pos]
	var next_queue = []
	while steps < max_steps:
		while !queue.empty():
			var current = queue.pop_back()
			for n in neighbors:
				var next_tile = current + n
				if checked.has(next_tile): continue
				if !is_in_grid(next_tile): continue
				if has_unit(next_tile):
					var unit = get_unit(next_tile)
					if unit._player_id != owner_id: continue
				checked.append(next_tile)
				if !is_zone_control(next_tile, owner_id) or get_unit(start_pos).atributes.is_swift: next_queue.append(next_tile)
				if !is_ocupied(next_tile): out.append(next_tile)
		steps += 1
		queue = next_queue.duplicate()
		next_queue.clear()
	return out


## converts Vector2 to a string readable by the grid
func _str(pos: Vector2) -> String:
	return (str(pos.x) + "," + str(pos.y))

## checks if pos is in grid before apending it to an array. Mainly to not start writing so many ifs
func _append(array: Array, pos: Vector2) -> void:
	if is_in_grid(pos):
		array.append(pos)
	
