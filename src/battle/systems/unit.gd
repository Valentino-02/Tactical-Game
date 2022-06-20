extends Resource
class_name Unit

signal died(unit)
signal has_acted(has, unit)

var card_reference_name : String # to return the corresponding card to hand when unit dies
var pos : Vector2
var has_acted := false setget set_has_acted
var is_engaged := false
var health: int setget set_health
var max_health
var is_archer : bool
var is_cavalry : bool
var damage : int
var defence : int
var min_range : int
var max_range : int
var movement : int

var _player_id = null
var _name: String
var _max_health: int
var _is_archer : bool
var _is_cavalry : bool
var _damage : int
var _defence: int
var _min_range: int
var _max_range: int
var _movement: int
var _atributes_to_add

var atributes := {
	"is_quick_shoting": false, # resets to false at end of turn. lets archers to attack after moving
	"quick_shot_trigger": 0, # if moved tiles is higher or equal than this, sets quick_shoting to true
	
	"has_round_attack" : false, # attacks sorrounding tiles in melee
	"aoe" : 0, # range of sorrounding tiles that also get attacked

	"cover" : 0, # bonus defence against ranged attacks
	"polearm" : 0, # bonus damage against cavalry
	"has_pierce" : false, # ignores defence
	"has_berserk" : false, # gives a second turn if attack kills
	"is_berserking" : false, # resets to false at end of turn.
	"steal" : 0, # gain gold when attacking
	"is_quick": false, # can attack after moving if it was engaged
	"is_swift": false, # ignores zone of control

	"is_charging" : false, # resets to false at end of turn. gives bonus damage
	"charge_trigger" : 0, # if moved tiles is higher or equal than this, sets is_charging to true
	"charge_damage" : 0, # bonus damage when charging
	
	"healing_aura" : 0, # heals allies in a radious at end of turn
	"healing_aura_range" : 0, 
	"damage_aura" : 0, # damage enemies in a radious at end of turn
	"damage_aura_range" : 0,
	"auto_heal" : 0, # heals self at the end of turn
}

func _init(card_info, initial_pos, player_id):
	if card_info[0] != "unit":
		print("card info type is not unit")
		return 
	_player_id = player_id
	_name = card_info[1]
	_max_health = card_info[3]
	_is_archer = true if (card_info[4] == 1) else false
	_is_cavalry = true if (card_info[5] == 1) else false
	_damage = card_info[6]
	_defence = card_info[7]
	_min_range = card_info[8]
	_max_range = card_info[9]
	_movement = card_info[10]
	_atributes_to_add = card_info[11]
	
	pos = initial_pos
	max_health = _max_health
	is_archer = _is_archer
	is_cavalry = _is_cavalry
	health = _max_health
	damage = _damage
	defence = _defence
	min_range = _min_range
	max_range = _max_range
	movement = _movement
	
	for key in _atributes_to_add:
		atributes[key] = _atributes_to_add[key]


func set_health(value):
	health = value
	health = clamp(health, 0, max_health)
	if health == 0:
		emit_signal("died", self)

func set_has_acted(value):
	has_acted = value
	emit_signal("has_acted", value, self)
