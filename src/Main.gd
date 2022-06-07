extends Node2D

const card_database = preload("res://src/cards/card_database.gd")

func _ready():
	var card = UnitCard.new(card_database.DATA.infantry)
	var card2 = UnitCard.new(card_database.DATA.horse_archer)
	var player1 = Player.new([card, card, card, card])
	var player2 = Player.new([card, card, card])
	var battle = BattleManager.new(player1, player2)
	battle._player_1.draw_cards(2)
	battle._player_1.gain_gold()
	battle._player_2.draw_cards(2)
	battle._player_2.gain_gold()
	battle.play_card(battle._player_1, card, Vector2(0,0))
	battle.play_card(battle._player_1, card, Vector2(1,1))
	battle.play_card(battle._player_2, card, Vector2(1,2))






