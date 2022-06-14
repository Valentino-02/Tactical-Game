extends Node2D

var _card_database = preload("res://src/cards/card_database.gd")
var _unit_card_container = preload("res://src/cards/UnitCardContainer.tscn")
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
	var i = 0
	for unit_name in unit_names:
		var unit_card_info = UnitCardInfo.new(_card_database.UNITS[unit_name])
		var unit_container = _unit_card_container.instance()
		unit_container.info = unit_card_info
		unit_container.id = i
		unit_container.name = str("infantry, id: ", i)
		i += 1
		deck.append(unit_container)
	return deck
