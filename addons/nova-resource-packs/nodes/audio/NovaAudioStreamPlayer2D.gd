extends AudioStreamPlayer2D

enum AudioTypes { SFX, MUSIC }
@export var AudioType: AudioTypes
@export var AudioId: StringName
@export var Loop: bool = false


func _ready() -> void:
	match AudioType:
		AudioTypes.SFX:
			NovaAudio.ReloadSfx.connect(_reload_stream)
		AudioTypes.MUSIC:
			NovaAudio.ReloadMusic.connect(_reload_stream)
	if Loop:
		finished.connect(play)
	
	await _nova_ready()


func _nova_ready() -> void:
	await get_tree().create_timer(0.3).timeout
	play()


func toggle_loop() -> void:
	if Loop:
		finished.disconnect(play)
	else:
		finished.connect(play)
	Loop = !Loop


func _reload_stream() -> void:
	var will_play: bool = is_playing()
	match AudioType:
		AudioTypes.SFX:
			stream = NovaAudio.get_sfx(AudioId)
		AudioTypes.MUSIC:
			stream = NovaAudio.get_music(AudioId)
	
	if will_play:
		play()
