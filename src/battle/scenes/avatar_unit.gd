extends Node2D


var has_acted setget set_has_acted
var player_id
var info

func _ready():
	if player_id == 1:
		$ColorRect.modulate = Color(0.2, 0.2, 0.8)
	if player_id == 2:
		$ColorRect.modulate = Color(0.8, 0.2, 0.2)


func update_texture(texture: Texture):
	var reference_frames: SpriteFrames = $AnimatedSprite.frames
	var updated_frames = SpriteFrames.new()
	
	for animation in reference_frames.get_animation_names():
		if animation != "default":
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
			
			for i in reference_frames.get_frame_count(animation):
				var updated_texture: AtlasTexture = reference_frames.get_frame(animation, i).duplicate()
				updated_texture.atlas = texture
				updated_frames.add_frame(animation, updated_texture)

	updated_frames.remove_animation("default")

	$AnimatedSprite.frames = updated_frames

func set_has_acted(value):
	has_acted = value
	if has_acted:
		print("has_acted")
		modulate = Color(0.5, 0.5, 0.5)
	if !has_acted:
		print("has_not_acted")
		modulate = Color(1, 1, 1)
