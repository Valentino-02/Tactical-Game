extends Node
class_name UnitCard


var _name: String
var _type : String
var _cost: int
var _health: int
var _archer : bool
var _cavalry : bool
var _damage : int
var _defence: int
var _min_range: int
var _max_range: int
var _movement: int
var _ability = null
var _card_info : Array


func _init(card_info):
	if card_info[0] != "unit":
		print("card info type is not unit")
		return 
	_type = card_info[0]
	_name = card_info[1]
	_cost = card_info[2]
	_health = card_info[3]
	_archer = true if (card_info[4] == 1) else false
	_cavalry = true if (card_info[5] == 1) else false
	_damage = card_info[6]
	_defence = card_info[7]
	_min_range = card_info[8]
	_max_range = card_info[9]
	_movement = card_info[10] 
	_ability = card_info[11]
	_card_info = card_info
	

