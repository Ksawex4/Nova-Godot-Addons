extends AudioStreamPlayer2D

enum AudioTypes { SFX, MUSIC }

## if its stored in [code]"sfx"[/code] or [code]"music"[/code] in your [code]"audio"[/code] part of your data.json
@export var AudioType: AudioTypes
## Audio id from [code]"audio"[/code] [code]"sfx/music"[/code] part of your data.json with your assets with the second one depending on AudioType
@export var AudioId: StringName
## If the audio should loop
@export var Loop: bool = false


func _ready() -> void:
	match AudioType:
		AudioTypes.SFX:
			NovaAudio.ReloadSfx.connect(_reload_stream)
			stream = NovaAudio.get_sfx(AudioId)
		AudioTypes.MUSIC:
			NovaAudio.ReloadMusic.connect(_reload_stream)
			stream = NovaAudio.get_music(AudioId)
	if Loop:
		finished.connect(play)
	
	if autoplay:
		play()
	
	await _nova_ready()


func _nova_ready() -> void:
	pass


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
