extends Resource
class_name BattleManager

const GRID = preload("res://src/battle/systems/grid.tres")
const _map_size = Vector2(10, 10)


var _player_1
var _player_2
var player_on_turn


func _init(deck_1, deck_2):
	GRID.create_empty_grid(_map_size.x, _map_size.y)
	_player_1 = Player.new(deck_1, 1)
	_player_2 = Player.new(deck_2, 2)

func change_turn():
	if player_on_turn == 1:
		player_on_turn = 2
		_player_1.end_turn()
		_player_2.start_turn()
	else:
		player_on_turn = 1
		_player_2.end_turn()
		_player_1.start_turn()

func get_player_on_turn():
	if player_on_turn == 1:
		return _player_1
	else:
		return _player_2

func play_card(player, card, pos: Vector2)-> void:
	player.play_card(card)
	
	if card.info._type == "unit":
		var unit = Unit.new(card.info._info_array, pos, player)
		GRID.add_unit(unit, pos)

func move_unit(from: Vector2, to: Vector2) -> void:
	var unit = GRID.get_unit(from)
	GRID.move_unit(from, to)
	unit.pos = to

func attack(attacker_pos, defender_pos) -> void:
	var attacker = GRID.get_unit(attacker_pos)
	var defender =  GRID.get_unit(defender_pos)
	assert(attacker.player != defender.player, 
		"attacker %s and defender %s are from the same team" %[attacker, defender])
	defender.receive_attack(attacker)
