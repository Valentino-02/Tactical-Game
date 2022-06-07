extends Resource
class_name BattleManager

const GRID = preload("res://src/battle/systems/grid.tres")

var _player_1
var _player_2


func _init(player_1, player_2):
	GRID.create_empty_grid(5,5)
	_player_1 = player_1
	_player_2 = player_2


func play_card(player, card, pos: Vector2)-> void:
	player.play_card(card)
	
	if card._type == "unit":
		var unit = Unit.new(card._card_info, pos, player)
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
	



