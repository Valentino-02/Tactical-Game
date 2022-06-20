extends Resource
class_name BattleManager

const GRID = preload("res://src/battle/systems/grid.tres")
const MAP_SIZE := Vector2(10, 10)

signal unit_added(unit)
signal unit_moved(from, to)
signal unit_died(unit)
signal unit_has_acted(has, unit)

var _player_1: Player
var _player_2: Player
var _player_on_turn: Player
var _player_1_units: Array
var _player_2_units: Array


func _init(deck_1, deck_2):
	GRID.create_empty_grid(MAP_SIZE.x, MAP_SIZE.y)
	_player_1 = Player.new(deck_1, 1)
	_player_2 = Player.new(deck_2, 2)

func change_turn():
	if _player_on_turn == _player_1:
		_player_on_turn = _player_2
		_player_1.end_turn()
		_player_2.start_turn()
		for unit in _player_1_units:
			if !unit.has_acted:
				unit_end_turn(unit)
			unit.has_acted = false
	elif _player_on_turn == _player_2:
		_player_on_turn = _player_1
		_player_2.end_turn()
		_player_1.start_turn()
		for unit in _player_2_units:
			if !unit.has_acted:
				unit_end_turn(unit)
			unit.has_acted = false

func play_card(card, pos: Vector2)-> void:
	var player_id = card.player_id
	if player_id == 1: _player_1.play_card(card)
	if player_id == 2: _player_2.play_card(card)
	
	if card.info._type == "unit":
		var unit = Unit.new(card.info._info_array, pos, player_id)
		unit.card_reference_name = card.name
		GRID.add_unit(unit, pos)
		if player_id == 1: _player_1_units.append(unit)
		if player_id == 2: _player_2_units.append(unit)
		unit.connect("died", self, "_on_unit_died")
		unit.connect("has_acted", self, "_on_unit_has_acted")
		emit_signal("unit_added", unit)

func move_unit(from: Vector2, to: Vector2) -> void:
	var unit = GRID.get_unit(from)
	var was_engaged = true if unit.is_engaged else false
	GRID.move_unit(from, to)
	unit.pos = to
	emit_signal("unit_moved", from, to)
	_check_for_engaged()
	if unit.atributes.quick_shot_trigger > 0:
		if GRID.get_distance(from, to) >= unit.atributes.quick_shot_trigger:
			unit.atributes.is_quick_shoting = true
	if unit.atributes.charge_trigger > 0:
		if GRID.get_distance(from, to) >= unit.atributes.charge_trigger:
			unit.atributes.is_charging = true
	
	if was_engaged and !unit.atributes.is_quick:
		unit_end_turn(unit)
		return
	if unit.is_archer : 
		if !unit.atributes.is_quick_shoting:
			unit_end_turn(unit)


func attack(attacker_pos: Vector2, defender_pos: Vector2) -> void:
	var attacker = GRID.get_unit(attacker_pos)
	var defender =  GRID.get_unit(defender_pos)
	assert(attacker._player_id != defender._player_id, 
		"attacker %s and defender %s are from the same team" %[attacker, defender]) 
	var aa = attacker.atributes
	var da = defender.atributes
	
	if aa.has_round_attack:
		for tile in GRID.get_tiles_in_range(attacker_pos, 1):
			if GRID.has_enemy(tile, attacker._player_id):
				_receive_attack(attacker, GRID.get_unit(tile))
		return
	
	if aa.aoe > 0:
		for tile in GRID.get_tiles_in_ranges(defender_pos, 1, aa.aoe):
			if GRID.has_enemy(tile, attacker._player_id):
				_receive_attack(attacker, GRID.get_unit(tile))
	
	if aa.steal > 0:
		_player_on_turn.gold += aa.steal
	
	_receive_attack(attacker, defender)
	unit_end_turn(attacker)

func _receive_attack(attacker: Unit, defender: Unit) -> void:
	var aa = attacker.atributes
	var da = defender.atributes
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

func _check_for_engaged():
	for unit in _player_1_units + _player_2_units:
		if GRID.is_zone_control(unit.pos, unit._player_id):
			unit.is_engaged = true
		else:
			unit.is_engaged = false

func unit_end_turn(unit: Unit) -> void:
	unit.has_acted = true
	var ua = unit.atributes
	ua.is_charging = false
	ua.is_quick_shoting = false
	if ua.is_berserking:
		ua.is_berserking = false
		unit.has_acted = false
	
	if ua.healing_aura > 0:
		for tile in GRID.get_tiles_in_ranges(unit.pos, 1, ua.healing_aura_range):
			if GRID.has_ally(tile, unit._player_id):
				GRID.get_unit(tile).health += ua.healing_aura
	
	if ua.damage_aura > 0:
		for tile in GRID.get_tiles_in_ranges(unit.pos, 1, ua.damage_aura_range):
			if GRID.has_enemy(tile, unit._player_id): 
				GRID.get_unit(tile).health -= ua.damage_aura
	
	if ua.auto_heal > 0:
		unit.health += ua.auto_heal

func _on_unit_died(unit: Unit) -> void:
	emit_signal("unit_died", unit)
	GRID.remove_unit(unit.pos) 
	if unit._player_id == 1: 
		_player_1_units.erase(unit)
		_player_1.return_card(unit.card_reference_name)
	if unit._player_id == 2: 
		_player_2_units.erase(unit)
		_player_2.return_card(unit.card_reference_name)


func _on_unit_has_acted(has, unit):
	emit_signal("unit_has_acted",has, unit)



