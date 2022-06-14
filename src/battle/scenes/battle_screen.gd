extends Node2D


enum S {idle, card_selected}

onready var board = $Board
onready var card_holder = $CardHolder
onready var board_holder = $BoardHolder

var battle_manager : BattleManager
var is_mouse_on_map setget set_is_mouse_on_map

var _board_unit = preload("res://src//battle/scenes/BoardUnit.tscn")
var _state = S.idle setget set_state
var _prev_state setget set_prev_state
var selected_card
var selected_card_offset


func _ready():
	board.draw_map(battle_manager._map_size)
	_connect_signals()
	battle_manager.player_on_turn = 1
	battle_manager._player_1.start_turn()

func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position()
	board.tile_pos = board.map.world_to_map(mouse_pos) 
	if _is(S.card_selected):
		selected_card.global_position = mouse_pos + selected_card_offset
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				pass 
			else:
				if _is(S.card_selected):
					if is_mouse_on_map and !battle_manager.GRID.is_ocupied(board.tile_pos):
						_play_card()
						_go(S.idle)
					_go(S.idle)

func _play_card():
	battle_manager.play_card(battle_manager.get_player_on_turn(), selected_card, board.tile_pos)
	card_holder.remove_card(selected_card)
	var board_unit = _board_unit.instance()
	board_unit.info = selected_card.info
	board.add_entity(board_unit, board.tile_pos)

func set_is_mouse_on_map(value):
	is_mouse_on_map = value
	if _is(S.card_selected):
		if is_mouse_on_map:
			selected_card.modulate = Color(1, 1, 1, 0.15)
		else: 
			selected_card.modulate = Color(1, 1, 1, 0.5)


################################################################################
##----------------------------------Signals-----------------------------------##
################################################################################


func _connect_signals() -> void:
	battle_manager._player_1.connect("card_drawn", self, "_on_card_drawn")
	battle_manager._player_2.connect("card_drawn", self, "_on_card_drawn")
	battle_manager._player_1.connect("card_discarded", self, "_on_card_discarded")
	battle_manager._player_2.connect("card_discarded", self, "_on_card_discarded")
	battle_manager._player_1.connect("health_changed", self, "_on_health_changed")
	battle_manager._player_2.connect("health_changed", self, "_on_health_changed")
	battle_manager._player_1.connect("gold_changed", self, "_on_gold_changed")
	battle_manager._player_2.connect("gold_changed", self, "_on_gold_changed")
	for card in (battle_manager._player_1._deck + battle_manager._player_2._deck):
		card.connect("card_entered", self, "_on_card_entered")
		card.connect("card_exited", self, "_on_card_exited")
		card.connect("card_clicked", self, "_on_card_clicked")

func _on_card_drawn(card) -> void:
	card_holder.add_card(card)

func _on_card_discarded(card) -> void:
	card_holder.remove_card(card)

func _on_health_changed(value) -> void:
	$Health.text = str("Health: ",value,"/",battle_manager._player_1._max_health)

func _on_gold_changed(value) -> void:
	$Gold.text = str("Gold: ",value)

func _on_EndTurn_pressed():
	battle_manager.change_turn()
	$Turn.text = str("Turn: Player ",battle_manager.player_on_turn)

func _on_Deck_pressed():
	if battle_manager.player_on_turn == 1:
		print(battle_manager._player_1._deck)
	if battle_manager.player_on_turn == 2:
		print(battle_manager._player_2._deck)

func _on_Discard_pressed():
	if battle_manager.player_on_turn == 1:
		print(battle_manager._player_1._discard_deck)
	if battle_manager.player_on_turn == 2:
		print(battle_manager._player_2._discard_deck)

func _on_card_entered(card):
	if _is(S.idle):
		card.position.y += -25

func _on_card_exited(card):
	if _is(S.idle):
		card.position.y += 25

func _on_card_clicked(card):
	if _is(S.idle):
		if battle_manager.get_player_on_turn().can_play(card):
			selected_card = card
			_go(S.card_selected)
		else:
			print("not enough gold")


################################################################################
##------------------------- State Manager ------------------------------------##
################################################################################


func set_state(value):
	_state = value
	if _state == S.card_selected:
		selected_card_offset = selected_card.global_position - get_global_mouse_position()
		selected_card.modulate = Color(1, 1, 1, 0.5)

func set_prev_state(value):
	_prev_state = value
	if _prev_state == S.card_selected:
		selected_card.modulate = Color(1, 1, 1, 1)
		selected_card = null
		card_holder.reorder_cards()

func _go(state):
	self._prev_state = _state
	self._state = state

func _is(state) -> bool:
	if _state == state:
		return true
	else:
		return false
