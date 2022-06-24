extends Node2D

var _card_database = preload("res://src/cards/card_database.gd")
var _card_unit = preload("res://src/cards/CardUnit.tscn")
var _card_structure = preload("res://src/cards/CardStructure.tscn")
var _card_weapon = preload("res://src/cards/CardWeapon.tscn")
var list = ["militia", "militia", "archer", "archer", "horseman", "horseman", "hoplite", "hoplite",
"camel_rider", "camel_rider", "slinger", "slinger", "scout", "scout", "crossbowman", "crossbowman",
"templar", "templar", "skirmisher", "skirmisher", "cataphract", "legionary", "longbowman", "knight"]
var list_2 = []
var list_3 = []
var list_4 = []


func _ready():
	randomize()
	var deck_1 = create_deck(list, list_3, list_4)
	var deck_2 = create_deck(list, list_3, list_4)
	var battle_manager = BattleManager.new(deck_1, deck_2)
	var battle_board = load("res://src/battle/scenes/BattleScreen.tscn").instance()
	battle_board.battle_manager = battle_manager
	add_child(battle_board)


func create_deck(unit_names: Array, structure_names: Array, weapon_names) -> Array:
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
		
	for structure_name in structure_names:
		var j = 0
		var card_info_structure = CardInfoStructure.new(_card_database.STRUCTURES[structure_name])
		var card_structure = _card_structure.instance()
		card_structure.info = card_info_structure
		for name in list_of_names:
			if name == card_structure.info._name: 
				j += 1
		card_structure.name = str(card_structure.info._name, "_", j)
		list_of_names.append(card_structure.info._name)
		card_structure.id = i
		i += 1
		deck.append(card_structure)
		
	for weapon_name in weapon_names:
		var j = 0
		var card_info_weapon = CardInfoWeapon.new(_card_database.WEAPONS[weapon_name])
		var card_weapon = _card_weapon.instance()
		card_weapon.info = card_info_weapon
		for name in list_of_names:
			if name == card_weapon.info._name: 
				j += 1
		card_weapon.name = str(card_weapon.info._name, "_", j)
		list_of_names.append(card_weapon.info._name)
		card_weapon.id = i
		i += 1
		deck.append(card_weapon)
	return deck
