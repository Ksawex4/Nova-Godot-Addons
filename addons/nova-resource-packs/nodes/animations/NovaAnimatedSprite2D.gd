extends AnimatedSprite2D

@export var AnimationId: StringName = &"missing"
@export var AnimationName: StringName = &"default"
@export var DefaultAnimationName: StringName = &"default"
@export var Autoplay: bool = false
@export var DuplicateSpriteFrames: bool = false
@export var BaseTextureSizeId: StringName = &"missing"
@export var IsBaseTextureSheet: bool = false
var BaseTextureSize: Vector2 = Vector2(64, 64)

func _ready() -> void:
	BaseTextureSize = NovaTexture.TextureSizes[BaseTextureSizeId]
	
	sprite_frames = NovaAnimation.get_animation(AnimationId, DuplicateSpriteFrames)
	
	if IsBaseTextureSheet:
		var frames: Vector2 = Vector2(NovaAnimation.BaseAnimationsData[AnimationId].get("frame-x", 2), NovaAnimation.AnimationsData[AnimationId].get("frame-y", 2))
		BaseTextureSize /= frames
	_update_scale()
	
	NovaAnimation.ReloadAnimation.connect(_reload_animation)
	frame_changed.connect(_update_scale)
	
	if Autoplay:
		play(AnimationName)
	await _nova_ready()


func _nova_ready() -> void:
	pass


func _update_scale() -> void:
	var texture: Texture = sprite_frames.get_frame_texture(animation, frame)
	scale = BaseTextureSize / texture.get_size()


func _reload_animation() -> void:
	var will_play: bool = is_playing()
	var animation_name: StringName = animation
	
	sprite_frames = NovaAnimation.get_animation(AnimationId, DuplicateSpriteFrames)
	_update_scale()
	if will_play:
		play(animation_name)
