extends Node2D

var _card_database = preload("res://src/cards/card_database.gd")
var _card_unit = preload("res://src/cards/CardUnit.tscn")
var list = ["infantry", "infantry", "infantry", "infantry", "infantry"]
var list_2 = ["archer", "archer", "archer", "archer", "archer"]


func _ready():
	var deck_1 = create_deck(list)
	var deck_2 = create_deck(list_2)
	var battle_manager = BattleManager.new(deck_1, deck_2)
	var battle_board = load("res://src/battle/scenes/BattleScreen.tscn").instance()
	battle_board.battle_manager = battle_manager
	add_child(battle_board)


func create_deck(unit_names: Array) -> Array:
	var deck = []
	var list_of_names = []
	var i = 0
	for unit_name in unit_names:
		var j = 0
		var card_info_unit = CardInfoUnit.new(_card_database.UNITS[unit_name])
		var card_unit = _card_unit.instance()
		card_unit.info = card_info_unit
		for name in list_of_names:
			if name == card_unit.info._name: 
				j += 1
		card_unit.name = str(card_unit.info._name, "_", j)
		list_of_names.append(card_unit.info._name)
		card_unit.id = i
		i += 1
		deck.append(card_unit)
	return deck
