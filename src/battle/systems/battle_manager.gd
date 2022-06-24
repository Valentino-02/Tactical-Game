extends Resource
class_name BattleManager

const GRID = preload("res://src/battle/systems/grid.tres")
const MAP_SIZE := Vector2(10, 10)

signal entity_added(entity)
signal unit_moved(from, to)
signal entity_died(rntity)
signal unit_has_acted(has, unit)
signal gold_mine_owner_changed(mine)

var _player_1: Player
var _player_2: Player
var _player_on_turn: Player
var _player_1_units: Array
var _player_2_units: Array
var _player_1_structures : Array
var _player_2_structures : Array
var _gold_mine_1_positions := [Vector2(0,4), Vector2(0,5), Vector2(1,4), Vector2(1,5)]
var _gold_mine_2_positions := [Vector2(8,4), Vector2(8,5), Vector2(9,4), Vector2(9,5)]
var _gold_mines := []
var _player_1_castle_positions := [Vector2(4,9), Vector2(5,9)]
var _player_2_castle_positions := [Vector2(4,0), Vector2(5,0)]


func _init(deck_1, deck_2):
	GRID.create_empty_grid(MAP_SIZE.x, MAP_SIZE.y)
	_gold_mines.append(GoldMine.new(_gold_mine_1_positions))
	_gold_mines.append(GoldMine.new(_gold_mine_2_positions))
	for mine in _gold_mines:
		GRID.add_gold_mine(mine)
	_player_1 = Player.new(deck_1, 1)
	_player_2 = Player.new(deck_2, 2)
	for pos in _player_1_castle_positions:
		var castle = Castle.new(pos, 1)
		GRID.add_structure(castle, pos)
		castle.connect("damaged", self, "_on_castle_damaged")
	for pos in _player_2_castle_positions:
		var castle = Castle.new(pos, 2)
		GRID.add_structure(castle, pos)
		castle.connect("damaged", self, "_on_castle_damaged")

func get_deploy_unit_tiles(player_id) -> Array:
	if player_id == 1:
		return GRID.get_deploy_tiles(_player_1_castle_positions)
	else :
		return GRID.get_deploy_tiles(_player_2_castle_positions)

func get_deploy_structure_tiles(player_id) -> Array:
	var extra_deployers: Array
	var castle_positions
	castle_positions = _player_1_castle_positions if player_id == 1 else _player_2_castle_positions
	for entity in _get_units(player_id) + _get_structures(player_id):
		extra_deployers.append(entity.pos)
	return GRID.get_deploy_tiles(castle_positions + extra_deployers)

func get_deploy_weapon_tiles(player_id) -> Array:
	var out: Array
	for structure in _get_structures(player_id):
		if structure.abilities.supplier_range > 0:
			for tile in GRID.get_tiles_in_ranges(structure.pos, 1, structure.abilities.supplier_range):
				if GRID.has_ally_unit(tile, player_id):
					out.append(tile)
	for tile in GRID.get_all_deploy_tiles(_get_castle_positions(player_id)):
		if GRID.has_ally_unit(tile, player_id) and !out.has(tile): 
			out.append(tile)
	return out

func change_turn():
	if _player_on_turn == _player_1:
		_player_on_turn = _player_2
		_player_1.end_turn()
		_player_2.start_turn()
		for unit in _player_1_units:
			if !unit.has_acted:
				unit_end_turn(unit)
			unit.has_acted = false
		for structure in _player_1_structures:
			structure_end_turn(structure)
	elif _player_on_turn == _player_2:
		_player_on_turn = _player_1
		_player_2.end_turn()
		_player_1.start_turn()
		for unit in _player_2_units:
			if !unit.has_acted:
				unit_end_turn(unit)
			unit.has_acted = false
		for structure in _player_2_structures:
			structure_end_turn(structure)

func play_card(card, pos: Vector2)-> void:
	var player_id = card.player_id
	_get_player(player_id).play_card(card)
	
	if card.info._type == "unit":
		var unit = Unit.new(card.info._info_array, pos, player_id)
		unit.card_reference_name = card.name
		GRID.add_unit(unit, pos)
		if player_id == 1: _player_1_units.append(unit)
		if player_id == 2: _player_2_units.append(unit)
		unit.connect("died", self, "_on_entity_died")
		unit.connect("has_acted", self, "_on_unit_has_acted")
		emit_signal("entity_added", unit)
	
	if card.info._type == "structure":
		var structure = Structure.new(card.info._info_array, pos, player_id)
		structure.card_reference_name = card.name
		GRID.add_structure(structure, pos)
		if player_id == 1: _player_1_structures.append(structure)
		if player_id == 2: _player_2_structures.append(structure)
		structure.connect("died", self, "_on_entity_died")
		emit_signal("entity_added", structure)
	
	if card.info._type == "weapon":
		var weapon = Weapon.new(card.info._info_array, player_id)
		weapon.card_reference_name = card.name
		var unit = GRID.get_unit(pos)
		unit.weapons.append(weapon)
		unit.weapon_count += 1

func move_unit(from: Vector2, to: Vector2) -> void:
	var unit = GRID.get_unit(from)
	var was_engaged = true if unit.is_engaged else false
	GRID.move_unit(from, to)
	unit.pos = to
	emit_signal("unit_moved", from, to)
	_check_for_engaged()
	if unit.abilities.quick_shot_trigger > 0:
		if GRID.get_distance(from, to) >= unit.abilities.quick_shot_trigger:
			unit.abilities.is_quick_shoting = true
	if unit.abilities.charge_trigger > 0:
		if GRID.get_distance(from, to) >= unit.abilities.charge_trigger:
			unit.abilities.is_charging = true
	
	if was_engaged and !unit.abilities.is_quick:
		unit_end_turn(unit)
		return
	if unit.is_archer : 
		if !unit.abilities.is_quick_shoting:
			unit_end_turn(unit)

func attack(attacker_pos: Vector2, defender_pos: Vector2) -> void:
	var attacker = GRID.get_unit(attacker_pos)
	var defender =  GRID.get_entity(defender_pos) 
	var aa = attacker.abilities
	
	if aa.has_round_attack:
		for tile in GRID.get_tiles_in_range(attacker_pos, 1):
			if GRID.has_enemy(tile, attacker._player_id):
				_receive_attack(attacker, GRID.get_entity(tile))
		return
	
	if aa.aoe > 0:
		for tile in GRID.get_tiles_in_ranges(defender_pos, 1, aa.aoe):
			if GRID.has_enemy(tile, attacker._player_id):
				_receive_attack(attacker, GRID.get_entity(tile))
	
	if aa.steal > 0:
		_player_on_turn.gold += aa.steal
	
	_receive_attack(attacker, defender)
	unit_end_turn(attacker)

func unit_end_turn(unit: Unit) -> void:
	unit.has_acted = true
	var ua = unit.abilities
	ua.is_charging = false
	ua.is_quick_shoting = false
	if ua.is_berserking:
		ua.is_berserking = false
		unit.has_acted = false
	
	if ua.healing_aura > 0:
		for tile in GRID.get_tiles_in_ranges(unit.pos, 1, ua.healing_aura_range):
			if GRID.has_ally_unit(tile, unit._player_id):
				GRID.get_unit(tile).health += ua.healing_aura
	
	if ua.damage_aura > 0:
		for tile in GRID.get_tiles_in_ranges(unit.pos, 1, ua.damage_aura_range):
			if GRID.has_enemy_unit(tile, unit._player_id): 
				GRID.get_unit(tile).health -= ua.damage_aura
	
	if ua.auto_heal > 0:
		unit.health += ua.auto_heal
	
	_check_gold_mines_owners()

func structure_end_turn(structure: Structure) -> void:
	var sa = structure.abilities
	
	if sa.healing_aura > 0:
		for tile in GRID.get_tiles_in_ranges(structure.pos, 1, sa.healing_aura_range):
			if GRID.has_ally_unit(tile, structure._player_id):
				GRID.get_unit(tile).health += sa.healing_aura
	
	if sa.damage_aura > 0:
		for tile in GRID.get_tiles_in_ranges(structure.pos, 1, sa.damage_aura_range):
			if GRID.has_enemy_unit(tile, structure._player_id): 
				GRID.get_unit(tile).health -= sa.damage_aura
	
	if sa.auto_heal > 0:
		structure.health += sa.auto_heal

func _receive_attack(attacker: Unit, defender) -> void:
	if defender._type == "unit":
		_unit_receive_attack(attacker, defender)
	if defender._type == "structure":
		_structure_receive_attack(attacker, defender)

func _unit_receive_attack(attacker: Unit, defender: Unit) -> void:
	var aa = attacker.abilities
	var da = defender.abilities
	var damage = attacker.damage
	var defence = defender.defence
	var effective_damage = damage - defence
	
	if GRID.get_distance(attacker.pos, defender.pos) == 1:
		pass
	
	if GRID.get_distance(attacker.pos, defender.pos) > 1:
		effective_damage -= da.cover
	
	if defender.is_cavalry:
		effective_damage += aa.polearm
	
	if aa.has_pierce:
		effective_damage += defence
	
	if aa.is_charging:
		effective_damage += aa.charge_damage
	
	if aa.has_berserk and effective_damage >= defender.health:
		aa.is_berserking = true
	
	if effective_damage <= 0 : effective_damage = 1
	defender.health -= effective_damage

func _structure_receive_attack(attacker: Unit, defender) -> void:
	defender.health -= attacker.damage

func _check_for_engaged():
	for unit in _player_1_units + _player_2_units:
		if GRID.is_zone_control(unit.pos, unit._player_id):
			unit.is_engaged = true
		else:
			unit.is_engaged = false

func _check_gold_mines_owners():
	for mine in _gold_mines:
		_check_gold_mine_owner(mine)
	
func _check_gold_mine_owner(mine: GoldMine):
	var prev_id = mine.owner_id
	var next_id = GRID.get_gold_mine_owner(mine)
	if prev_id == next_id: return
	if prev_id != 0:
		_get_player(prev_id).mines.erase(mine)
	if next_id != 0:
		_get_player(next_id).mines.append(mine)
	mine.owner_id = next_id
	emit_signal("gold_mine_owner_changed", mine)

func _get_units(player_id) -> Array:
	return _player_1_units if player_id == 1 else _player_2_units

func _get_structures(player_id) -> Array:
	return _player_1_structures if player_id == 1 else _player_2_structures

func _get_castle_positions(player_id) -> Array:
	return _player_1_castle_positions if player_id == 1 else _player_2_castle_positions

func _get_player(player_id) -> Player:
	return _player_1 if player_id == 1 else _player_2
	


func _on_entity_died(entity) -> void:
	emit_signal("entity_died",entity)
	if entity._player_id == 1: 
		_entity_died_cleanup(entity, _player_1, _player_1_units, _player_1_structures)
	if entity._player_id == 2: 
		_entity_died_cleanup(entity, _player_2, _player_2_units, _player_2_structures)

func _entity_died_cleanup(entity, player, player_units, player_structures) -> void:
	GRID.remove_entity(entity.pos)
	player.return_card(entity.card_reference_name)
	if entity._type == "unit":
		player_units.erase(entity)
		for weapon in entity.weapons:
			player.return_card(entity.card_reference_name)
	if entity._type == "structure":
		player_structures.erase(entity)

func _on_unit_has_acted(has, unit):
	emit_signal("unit_has_acted",has, unit)

func _on_castle_damaged(damage, player_id):
	if player_id == 1:
		_player_1.health -= damage
	if player_id == 2:
		_player_2.health -= damage
