extends Node2D


enum S {idle, card_selected, moving_unit, selecting_target}

onready var board = $Board
onready var hand = $Hand

var battle_manager : BattleManager
var is_mouse_on_map setget set_is_mouse_on_map

var _state = S.idle setget set_state
var _prev_state setget set_prev_state
var _selected_card
var _selected_card_offset
var _selected_unit
var _move_tiles setget set_move_tiles
var _attack_tiles setget set_attack_tiles


func _ready():
	board.draw_map(battle_manager.MAP_SIZE)
	_connect_signals()
	battle_manager._player_on_turn = battle_manager._player_1
	battle_manager._player_1.start_turn()

func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position()
	var mouse_tile_pos = board.map.world_to_map(mouse_pos) 
	board.tile_hovered = mouse_tile_pos
	
	if _is(S.card_selected):
		_selected_card.global_position = mouse_pos + _selected_card_offset
	
	if is_mouse_on_map and battle_manager.GRID.has_unit(mouse_tile_pos):
		var unit
		if unit != battle_manager.GRID.get_unit(mouse_tile_pos):
			unit = battle_manager.GRID.get_unit(mouse_tile_pos)
			$Display/Damage.text = str("Damage: ",unit._damage)
			$Display/Defence.text = str("Defence: ",unit._defence)
			$Display/Health.text = str("Health: ",unit.health)
			$Display/Movement.text = str("Movement: ",unit._movement)
			$Display/Range.text = str("Range: ",unit._min_range,"/",unit._max_range)
			$Display/UnitName.text = str("Name: ",unit._name)
	if is_mouse_on_map and !battle_manager.GRID.has_unit(mouse_tile_pos):
			$Display/Damage.text = str("Damage: ")
			$Display/Defence.text = str("Defence: ")
			$Display/Health.text = str("Helath: ")
			$Display/Movement.text = str("Movement: ")
			$Display/Range.text = str("Range: ")
			$Display/UnitName.text = str("Name: ")
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			
			if event.pressed:
				if _is(S.selecting_target):
					if mouse_tile_pos == _selected_unit.pos:
						_selected_unit.has_acted = true
						_go(S.idle)
					elif mouse_tile_pos in _attack_tiles and battle_manager.GRID.has_unit(mouse_tile_pos):
						var unit = battle_manager.GRID.get_unit(mouse_tile_pos)
						if unit._player_id != _selected_unit._player_id:
							battle_manager.attack(_selected_unit.pos, mouse_tile_pos)
							_selected_unit.has_acted = true
							_go(S.idle)
				
				if _is(S.moving_unit):
					if mouse_tile_pos == _selected_unit.pos:
						_go(S.selecting_target)
					elif mouse_tile_pos in _move_tiles:
						battle_manager.move_unit(_selected_unit.pos, mouse_tile_pos)
						_go(S.selecting_target)
					else:
						_go(S.idle)
				
				if _is(S.idle):
					if is_mouse_on_map:
						if battle_manager.GRID.has_unit(mouse_tile_pos):
							var unit = battle_manager.GRID.get_unit(mouse_tile_pos)
							if !unit.has_acted and unit._player_id == battle_manager._player_on_turn._player_id:
								_selected_unit = unit
								_go(S.moving_unit)
			
			else:
				if _is(S.card_selected):
					if is_mouse_on_map and !battle_manager.GRID.is_ocupied(mouse_tile_pos):
						battle_manager.play_card(_selected_card, mouse_tile_pos)
						_go(S.idle)
					_go(S.idle)


func set_is_mouse_on_map(value):
	is_mouse_on_map = value
	if _is(S.card_selected):
		if is_mouse_on_map:
			_selected_card.modulate = Color(1, 1, 1, 0.15)
		else: 
			_selected_card.modulate = Color(1, 1, 1, 0.5)

func set_move_tiles(value: Array):
	_move_tiles = value
	board.draw_move(value)

func set_attack_tiles(value: Array):
	_attack_tiles = value
	board.draw_attack(value)


################################################################################
##------------------------- State Manager ------------------------------------##
################################################################################


func set_state(value):
	_state = value
	if _state == S.idle:
		print("state = idle")
		_selected_card = null
	if _state == S.card_selected:
		print("state = card_selected")
		_selected_card_offset = _selected_card.global_position - get_global_mouse_position()
		_selected_card.modulate = Color(1, 1, 1, 0.5)
	if _state == S.moving_unit:
		print("state = moving_unit")
		self._move_tiles = battle_manager.GRID.get_walkable_tiles(_selected_unit.pos, _selected_unit._movement)
	if _state == S.selecting_target:
		print("state = selecting_target")
		self._attack_tiles = battle_manager.GRID.get_attackable_tiles(_selected_unit.pos, _selected_unit._min_range, _selected_unit._max_range)


func set_prev_state(value):
	_prev_state = value
	if _prev_state == S.card_selected:
		_selected_card.modulate = Color(1, 1, 1, 1)
		hand.reorder_cards()
	if _prev_state == S.moving_unit:
		self._move_tiles = []
	if _prev_state == S.selecting_target:
		self._attack_tiles = []


func _go(state):
	self._prev_state = _state
	self._state = state

func _is(state) -> bool:
	if _state == state:
		return true
	else:
		return false


################################################################################
##----------------------------------Signals-----------------------------------##
################################################################################


func _connect_signals() -> void:
	battle_manager._player_1.connect("card_drawn", self, "_on_card_drawn")
	battle_manager._player_2.connect("card_drawn", self, "_on_card_drawn")
	battle_manager._player_1.connect("card_used", self, "_on_card_used")
	battle_manager._player_2.connect("card_used", self, "_on_card_used")
	battle_manager._player_1.connect("health_changed", self, "_on_health_changed")
	battle_manager._player_2.connect("health_changed", self, "_on_health_changed")
	battle_manager._player_1.connect("gold_changed", self, "_on_gold_changed")
	battle_manager._player_2.connect("gold_changed", self, "_on_gold_changed")
	for card in (battle_manager._player_1._deck + battle_manager._player_2._deck):
		card.connect("card_entered", self, "_on_card_entered")
		card.connect("card_exited", self, "_on_card_exited")
		card.connect("card_clicked", self, "_on_card_clicked")
	battle_manager.connect("unit_added", board, "_on_unit_added")
	battle_manager.connect("unit_moved", board, "_on_unit_moved")
	battle_manager.connect("unit_died", board, "_on_unit_died")
	battle_manager.connect("unit_has_acted", board, "_on_unit_has_acted")

func _on_card_drawn(card) -> void:
	hand.add_card(card)

func _on_card_used(card) -> void:
	hand.remove_card(card)

func _on_health_changed(value) -> void:
	$Health.text = str("Health: ",value,"/",battle_manager._player_1._max_health)

func _on_gold_changed(value) -> void:
	$Gold.text = str("Gold: ",value)

func _on_EndTurn_pressed():
	battle_manager.change_turn()
	_go(S.idle)
	$Turn.text = str(battle_manager._player_on_turn)

func _on_card_entered(card):
	if _is(S.idle):
		card.position.y += -25

func _on_card_exited(card):
	if _is(S.idle):
		card.position.y += 25

func _on_card_clicked(card):
	if _is(S.idle):
		if battle_manager._player_on_turn.can_play(card):
			_selected_card = card
			_go(S.card_selected)
		else:
			print("not enough gold")
