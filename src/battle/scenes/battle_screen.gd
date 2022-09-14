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
var _selected_unit_prev_pos
var _move_tiles setget set_move_tiles
var _attack_tiles setget set_attack_tiles
var _deploy_tiles setget set_deploy_tiles


func _ready():
	board.draw_map(battle_manager.MAP_SIZE)
	for mine in battle_manager._gold_mines:
		board.draw_gold_mine(mine)
	_connect_signals()
	battle_manager._player_on_turn = battle_manager._player_1
	battle_manager._player_1.start_turn()

func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position()
	var mouse_tile_pos = board.map.world_to_map(mouse_pos)  
	board.tile_hovered = mouse_tile_pos
	if _is(S.card_selected):
		_selected_card.global_position = mouse_pos + _selected_card_offset
	_display_unit_info(mouse_tile_pos)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			
			if event.pressed:
				if _is(S.selecting_target):
					if mouse_tile_pos == _selected_unit.pos:
						battle_manager.unit_end_turn(_selected_unit)
						_go(S.idle)
					elif mouse_tile_pos in _attack_tiles and battle_manager.GRID.has_entity(mouse_tile_pos):
						var entity = battle_manager.GRID.get_entity(mouse_tile_pos)
						battle_manager.attack(_selected_unit.pos, mouse_tile_pos)
						_go(S.idle)
				
				if _is(S.moving_unit):
					if mouse_tile_pos == _selected_unit.pos:
						_go(S.selecting_target)
					elif mouse_tile_pos in _move_tiles:
						battle_manager.move_unit(_selected_unit.pos, mouse_tile_pos)
						if _selected_unit.has_acted:
							_go(S.idle)
						elif !_selected_unit.has_acted:
							_go(S.selecting_target)
					else:
						_go(S.idle)
				
				if _is(S.idle):
					self._move_tiles = []
					if is_mouse_on_map and battle_manager.GRID.has_ally_unit(mouse_tile_pos, battle_manager._player_on_turn._player_id):
						var unit = battle_manager.GRID.get_unit(mouse_tile_pos)
						if !unit.has_acted:
							_selected_unit = unit
							_selected_unit_prev_pos = _selected_unit.pos
							_go(S.moving_unit)
					if is_mouse_on_map and battle_manager.GRID.has_enemy_unit(mouse_tile_pos, battle_manager._player_on_turn._player_id):
						var unit = battle_manager.GRID.get_unit(mouse_tile_pos)
						self._move_tiles = battle_manager.GRID.get_walkable_tiles(unit.pos, unit._movement)
			
			
			else:
				if _is(S.card_selected):
					if _deploy_tiles.has(mouse_tile_pos):
						battle_manager.play_card(_selected_card, mouse_tile_pos)
					_go(S.idle)
					
		if event.button_index == BUTTON_RIGHT:
			
			if event.pressed:
				
				if _is(S.moving_unit):
					_go(S.idle)
				
				if _is(S.selecting_target):
					if _selected_unit_prev_pos == _selected_unit.pos:
						_go(S.idle)
					else:
						battle_manager.move_unit(_selected_unit.pos, _selected_unit_prev_pos)
						_go(S.idle)

func _display_unit_info(mouse_tile_pos):
	if is_mouse_on_map and battle_manager.GRID.has_unit(mouse_tile_pos):
		var unit = battle_manager.GRID.get_unit(mouse_tile_pos)
		var weapons := []
		for weapon in unit.weapons:
			weapons.append(weapon._name)
		$Display/Damage.text = str("Damage: ",unit.damage)
		$Display/Defence.text = str("Defence: ",unit.defence)
		$Display/Health.text = str("Health: ",unit.health)
		$Display/Movement.text = str("Movement: ",unit.movement)
		$Display/Range.text = str("Range: ",unit.min_range,"/",unit.max_range)
		$Display/Name.text = str("Name: ",unit._name)
		$Display/IsArcher.text = str("Is Archer: ",unit.is_archer)
		$Display/IsCavalry.text = str("Is Cavalry: ",unit.is_cavalry)
		$Display/Weapons.text = str("Weapons: ", weapons)
	elif is_mouse_on_map and battle_manager.GRID.has_structure(mouse_tile_pos):
		var structure = battle_manager.GRID.get_structure(mouse_tile_pos)
		$Display/Health.text = str("Health: ",structure.health)
		$Display/Name.text = str("Name: ",structure._name)
		$Display/Damage.text = ""
		$Display/Defence.text = ""
		$Display/Movement.text = ""
		$Display/Range.text = ""
		$Display/IsArcher.text = ""
		$Display/IsCavalry.text = ""
		$Display/Weapons.text = ""
	elif is_mouse_on_map and !battle_manager.GRID.has_unit(mouse_tile_pos):
		$Display/Damage.text = ""
		$Display/Defence.text = ""
		$Display/Health.text = ""
		$Display/Movement.text = ""
		$Display/Range.text = ""
		$Display/Name.text = ""
		$Display/IsArcher.text = ""
		$Display/IsCavalry.text = ""
		$Display/Weapons.text = ""

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

func set_deploy_tiles(value: Array):
	_deploy_tiles = value
	board.draw_deploy(value)



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
		if _selected_card.info._type == "unit":
			self._deploy_tiles = battle_manager.get_deploy_unit_tiles(battle_manager._player_on_turn._player_id)
		if _selected_card.info._type == "structure":
			self._deploy_tiles = battle_manager.get_deploy_structure_tiles(battle_manager._player_on_turn._player_id)
		if _selected_card.info._type == "weapon":
			self._deploy_tiles = battle_manager.get_deploy_weapon_tiles(battle_manager._player_on_turn._player_id)
	if _state == S.moving_unit:
		print("state = moving_unit")
		self._move_tiles = battle_manager.GRID.get_walkable_tiles(_selected_unit.pos, _selected_unit.movement)
	if _state == S.selecting_target:
		print("state = selecting_target")
		self._attack_tiles = battle_manager.GRID.get_attackable_tiles(_selected_unit.pos, _selected_unit.min_range, _selected_unit.max_range)

func set_prev_state(value):
	_prev_state = value
	if _prev_state == S.card_selected:
		_selected_card.modulate = Color(1, 1, 1, 1)
		hand.reorder_cards()
		self._deploy_tiles = []
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
	battle_manager.connect("entity_added", board, "_on_entity_added")
	battle_manager.connect("unit_moved", board, "_on_unit_moved")
	battle_manager.connect("entity_died", board, "_on_entity_died")
	battle_manager.connect("unit_has_acted", board, "_on_unit_has_acted")
	battle_manager.connect("gold_mine_owner_changed", board, "_on_gold_mine_owner_changed")

func _on_card_drawn(card) -> void:
	hand.add_card(card)

func _on_card_used(card) -> void:
	hand.remove_card(card)

func _on_health_changed(value) -> void:
	pass
#	$Health.text = str("Health: ",value,"/",battle_manager._player_1._max_health)

func _on_gold_changed(value) -> void:
	$Gold.text = str("Gold: ",value)

func _on_EndTurn_pressed():
	_go(S.idle)
	battle_manager.change_turn()
	$Turn.text = str(battle_manager._player_on_turn)
	$Health.text = str("Health: ", battle_manager._player_on_turn.health,"/",battle_manager._player_1._max_health)

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
