extends Node2D


func add_card(card):
	add_child(card)
	reorder_cards()

func remove_card(card):
	remove_child(card)
	reorder_cards()

func reorder_cards():
	var i = 0
	for child in get_children():
		child.position.y = 0
		child.position.x = i*200
		i += 1
	i = 0
