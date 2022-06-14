extends Node2D


var info


func _ready():
	pass

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
