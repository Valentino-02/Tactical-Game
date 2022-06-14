extends Resource

var _card_database = preload("res://src/cards/card_database.gd")
var _unit_card_container = preload("res://src/cards/UnitCardContainer.tscn")


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


