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
		for unit in _player_2_units:
			unit.has_acted = false
	elif _player_on_turn == _player_2:
		_player_on_turn = _player_1
		_player_2.end_turn()
		_player_1.start_turn()
		for unit in _player_1_units:
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
	GRID.move_unit(from, to)
	unit.pos = to
	emit_signal("unit_moved", from, to)

func attack(attacker_pos, defender_pos) -> void:
	var attacker = GRID.get_unit(attacker_pos)
	var defender =  GRID.get_unit(defender_pos)
	assert(attacker._player_id != defender._player_id, 
		"attacker %s and defender %s are from the same team" %[attacker, defender])
	defender.receive_attack(attacker)


func _on_unit_died(unit):
	emit_signal("unit_died", unit)
	print(GRID.has_unit(unit.pos))
	GRID.remove_unit(unit.pos) 
	print(GRID.has_unit(unit.pos))
	if unit._player_id == 1: 
		_player_1_units.erase(unit)
		_player_1.return_card(unit.card_reference_name)
	if unit._player_id == 2: 
		_player_2_units.erase(unit)
		_player_2.return_card(unit.card_reference_name)
	unit.queue_free()

func _on_unit_has_acted(has, unit):
	emit_signal("unit_has_acted",has, unit)
