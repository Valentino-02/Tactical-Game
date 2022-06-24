extends Resource
class_name Structure

signal died(structure)

var card_reference_name : String # to return the corresponding card to hand when structure dies
var pos : Vector2
var health: int setget set_health
var max_health

var _type
var _player_id 
var _name: String
var _max_health: int
var _abilities_to_add := {}

var abilities := {
	"supplier_range" : 0,
	"inspire_aura" : 0,
	"inspire_aura_range" : 0,
	"healing_aura" : 0, # heals allies in a radious at end of turn
	"healing_aura_range" : 0, 
	"damage_aura" : 0, # damage enemies in a radious at end of turn
	"damage_aura_range" : 0,
	"auto_heal" : 0, # heals self at the end of turn
}

func _init(card_info, initial_pos, player_id):
	if card_info[0] != "structure":
		print("card info type is not unit")
		return 
	_player_id = player_id
	_type = card_info[0]
	_name = card_info[1]
	_max_health = card_info[3]
	_abilities_to_add = card_info[4]
	
	pos = initial_pos
	max_health = _max_health
	health = _max_health
	
	for key in _abilities_to_add:
		abilities[key] = _abilities_to_add[key]


func set_health(value):
	health = value
	health = clamp(health, 0, max_health)
	if health == 0:
		emit_signal("died", self)

