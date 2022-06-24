extends Resource
class_name Castle

signal damaged(damage, player_id)

var card_reference_name : String # to return the corresponding card to hand when structure dies
var pos : Vector2
var health := 20 setget set_health

var _type := "structure"
var _player_id 
var _name := "castle"

func _init(initial_pos, player_id):
	_player_id = player_id
	pos = initial_pos

func set_health(value):
	var damage = health - value
	health = value
	emit_signal("damaged", damage, _player_id)
