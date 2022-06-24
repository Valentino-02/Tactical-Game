extends Resource
class_name Weapon

var card_reference_name : String # to return the corresponding card to hand when holder dies

var _type
var _player_id 
var _name: String
var _atributes_to_add := []
var _conditions := {}
var _abilities_to_add := {}

func _init(card_info,  player_id):
	_player_id = player_id
	_type = card_info[0]
	_name = card_info[1]
	_atributes_to_add = card_info[3]
	_abilities_to_add = card_info[4]
	_conditions = card_info[5]


