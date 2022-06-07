extends Node
class_name Player


var health : int
var gold: int

var _is_your_turn := false
var _max_health := 10
var _max_hand_size := 5
var _deck := []
var _draw_pool := []
var _used_pool := []
var _hand := []


func _init(deck):
	_deck = deck
	_draw_pool = _deck.duplicate()
	_draw_pool.shuffle()

func start_turn() -> void:
	assert(!_is_your_turn, "it is already %s turn" % self)
	_is_your_turn = true
	draw_cards(_max_hand_size)
	gain_gold()

func finish_turn() -> void:
	assert(_is_your_turn, "it is not %s turn" % self)
	_is_your_turn = false
	discard_hand()

func draw_cards(num: int) -> void:
	for i in range (0, num, 1):
		var cards_left = _draw_pool.size()
		if cards_left == 0:
			reshuffle_used()
		var card = _draw_pool.pop_back()
		_hand.append(card)

func discard(card) -> void:
	assert(_hand.has(card), "%s not in hand" %card)
	_hand.erase(card)
	_used_pool.append(card)

func discard_hand() -> void:
	_used_pool.append_array(_hand.duplicate()) 
	_hand.clear()

func reshuffle_used() -> void:
	_draw_pool.append_array(_used_pool.duplicate()) 
	_draw_pool.shuffle()
	_used_pool.clear()

func play_card(card) -> void:
	assert(_hand.has(card), "%s not in hand" %card)
	assert(card._cost <= gold, "not enough gold to play %s" %card)
	discard(card)
	gold -= card._cost

func gain_gold() -> void:
	gold += 5
