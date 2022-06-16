extends Node
class_name Unit


signal died(unit)
signal has_acted(has, unit)

var health: int setget set_health
var pos : Vector2
var has_acted : bool setget set_has_acted
var card_reference_name

var _card_info
var _player_id = null
var _name: String
var _is_archer : bool
var _is_cavalry : bool
var _cost: int
var _damage : int
var _defence: int
var _min_range: int
var _max_range: int
var _movement: int
var _max_health: int
var _ability = null


func _init(card_info, initial_pos, player_id):
	if card_info[0] != "unit":
		print("card info type is not unit")
		return 
	_card_info = card_info
	_name = card_info[1]
	_cost = card_info[2]
	_max_health = card_info[3]
	_is_archer = true if (card_info[4] == 1) else false
	_is_cavalry = true if (card_info[5] == 1) else false
	_damage = card_info[6]
	_defence = card_info[7]
	_min_range = card_info[8]
	_max_range = card_info[9]
	_movement = card_info[10]
	_ability = card_info[11]
	_player_id = player_id
	
	health = _max_health
	pos = initial_pos
	has_acted = false


func receive_attack(attacking_unit) -> void:
	var damage = attacking_unit._damage
	if (damage - _defence) <= 0:
		health -= 1
	else:
		self.health -= (damage - _defence)

func set_health(value):
	health = value
	health = clamp(health, 0, _max_health)
	if health == 0:
		print("oi")
		emit_signal("died", self)

func set_has_acted(value):
	has_acted = value
	emit_signal("has_acted", value, self)
	

