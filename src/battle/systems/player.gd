extends Node
class_name Player


signal card_drawn(card)
signal card_discarded(card)
signal health_changed(value)
signal gold_changed(value)

var health : int setget set_health
var gold: int setget set_gold

var _is_turn := false
var _max_health := 10
var _max_hand_size := 3
var _deck := []
var _discard_deck := []
var _hand := []
var _player_id 


func _init(deck, player_id):
	_deck = deck
	_player_id = player_id
	name = str("player_",player_id)
	for card in _deck:
		card.player_id = player_id
	_deck.shuffle()
	health = _max_health

func start_turn() -> void:
	assert(!_is_turn, "it is already %s turn" % self)
	_is_turn = true
	draw_cards(_max_hand_size)
	gain_gold()

func end_turn() -> void:
	assert(_is_turn, "it is not %s turn" % self)
	_is_turn = false
	discard_hand()

func draw_cards(num: int) -> void:
	for i in range (0, num, 1):
		var cards_left = _deck.size()
		if cards_left == 0:
			reshuffle_into_deck()
		var card = _deck.pop_back()
		_hand.append(card)
		emit_signal("card_drawn", card)

func discard(card) -> void:
	assert(_hand.has(card), "%s not in hand" %card)
	_hand.erase(card)
	_discard_deck.append(card)
	emit_signal("card_discarded", card)

func discard_hand() -> void:
	for card in _hand:
		emit_signal("card_discarded", card)
	_discard_deck.append_array(_hand.duplicate())
	_hand.clear()

func reshuffle_into_deck() -> void:
	_deck.append_array(_discard_deck.duplicate()) 
	_deck.shuffle()
	_discard_deck.clear()

func play_card(card) -> void:
	assert(_hand.has(card), "%s not in hand" %card)
	assert(card.info._cost <= gold, "not enough gold to play %s" %card)
	discard(card)
	self.gold -= card.info._cost

func can_play(card) -> bool:
	return card.info._cost <= gold

func gain_gold() -> void:
	self.gold += 5

func set_health(value) -> void:
	health = value
	health = clamp(health, 0, _max_health)
	emit_signal("health_changed", value)
	if health == 0:
		print(str("player_"),_player_id," died")

func set_gold(value) -> void:
	gold = value
	emit_signal("gold_changed", value)
