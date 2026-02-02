extends TextureRect

## Texture id from [code]"textures"[/code] part of your data.json with your assets
@export var TextureId: StringName = &"missing"

func _ready() -> void:
	texture = NovaTexture.get_texture(TextureId)
	NovaTexture.ReloadTexture.connect(_reload_texture)
	await _nova_ready()


func _nova_ready() -> void:
	pass


func _reload_texture() -> void:
	texture = NovaTexture.get_texture(TextureId)
