extends Resource
class_name CardInfoWeapon

var _info_array: Array
var _type: String
var _name: String 
var _cost: int
var _ability = null
var _img_path : String

func _init(info_array):
	assert(info_array[0] == "weapon", "card info type is not weapon")
	_info_array = info_array
	_type = info_array[0]
	_name = info_array[1]
	_cost = info_array[2]
	_ability = info_array[3]
	_img_path = str("res://assets/images/cards/weapons/",_name,".png")

