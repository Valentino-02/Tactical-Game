extends Resource
class_name CardInfoUnit

var _info_array: Array
var _type: String
var _name: String 
var _cost: int
var _health: int
var _archer: bool
var _cavalry: bool
var _damage: int
var _defence: int
var _min_range: int
var _max_range: int
var _move: int
var _ability = null
var _img_path : String

func _init(info_array):
	assert(info_array[0] == "unit", "card info type is not unit")
	_info_array = info_array
	_type = info_array[0]
	_name = info_array[1]
	_cost = info_array[2]
	_health = info_array[3]
	_archer = true if (info_array[4] == 1) else false
	_cavalry = true if (info_array[5] == 1) else false
	_damage = info_array[6]
	_defence = info_array[7]
	_min_range = info_array[8]
	_max_range = info_array[9]
	_move = info_array[10] 
	_ability = info_array[11]
	_img_path = str("res://assets/images/cards/units/",_name,".png")
