extends Node2D

signal card_entered(card)
signal card_exited(card)
signal card_clicked(card)

var info
var id
var player_id

func _ready():
	$ArtContainer/Art.texture = load(info._img_path)
	$ArtContainer/Art.scale *= $ArtContainer.rect_size/$ArtContainer/Art.texture.get_size()
	$Cost.text = str(info._cost)
	$Name.text = str(info._name)
#	$Ability.text = info._ability

func _on_Area2D_mouse_entered():
	emit_signal("card_entered", self)

func _on_Area2D_mouse_exited():
	emit_signal("card_exited", self)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		emit_signal("card_clicked", self)

