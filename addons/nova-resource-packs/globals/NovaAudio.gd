extends Node


var MusicStreamPlayer: AudioStreamPlayer
var CurrentMusicId: StringName = &"" # empty mean nothing
var Music: Dictionary[StringName, String]
var Sfx: Dictionary[StringName, AudioStream]
signal ReloadSfx()
signal ReloadMusic()


func add_music(id: StringName, path: String):
	print(!FileAccess.file_exists(path) and path.begins_with("user://"))
	print(!ResourceLoader.exists(path) and path.begins_with("res://"))
	if (!FileAccess.file_exists(path) and path.begins_with("user://")) and (!ResourceLoader.exists(path) and path.begins_with("res://")):
		push_warning("File doesn't exist path: %s id: %s" % [path, id])
		return
	
	Music.set(id, path)


func add_sfx(id: StringName, path: String):
	print(FileAccess.file_exists(path))
	print(ResourceLoader.exists(path))
	if (!FileAccess.file_exists(path) and path.begins_with("user://")) and (!ResourceLoader.exists(path) and path.begins_with("res://")):
		push_warning("File doesn't exist path: %s id: %s" % [path, id])
		Sfx.set(id, AudioStream.new())
		return
	
	var stream: AudioStream = _get_as_audio_stream(path)
	if stream != null:
		Sfx.set(id, stream)
		return
	push_warning("Failed to load audio stream %s at path %s, " % [id, path])
	Sfx.set(id, AudioStream.new())


func _get_as_audio_stream(path: String) -> AudioStream:
	var extension: String = path.get_file().get_extension()
	match extension:
		"ogg":
			if path.begins_with("res://"):
				return load(path)
			var stream: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(path)
			return stream
		
		"wav":
			if path.begins_with("res://"):
				return load(path)
			var stream: AudioStreamWAV = AudioStreamWAV.new().load_from_file(path)
			return stream
		
		_:
			push_warning(extension, " - unsupported extension, should be .wav or .ogg")
	
	return AudioStream.new()


func get_sfx(id: StringName) -> AudioStream:
	if Sfx.has(id):
		return Sfx[id]
	push_warning("Sfx with id: %s doesn't exist, returning new audio stream" % id)
	return AudioStream.new()


func get_music(id: StringName) -> AudioStream:
	var stream: AudioStream = AudioStream.new()
	if Music.has(id):
		stream = _get_as_audio_stream(Music[id])
		if stream != null:
			return stream
		push_warning("Failed to load Music %s with path %s" % [id, Music[id]])
	push_warning("Music with id: %s doesn't exist, returning new audio stream" % id)
	return AudioStream.new()


func get_music_path(id: StringName) -> String:
	if Music.has(id):
		return Music[id]
	push_warning("Music with id: %s doesn't exist, returning empty path id" % id)
	return ""


func play_music(id: StringName) -> void:
	if Music.has(id):
		var stream: AudioStream = get_music(id)
		if stream != null:
			MusicStreamPlayer.stream = stream
			MusicStreamPlayer.play()
			CurrentMusicId = id
			return
		push_warning("Failed to load music with id %s" % id)
		return
	push_warning("Music with id %s doesn't exist" % id)
	return


func load_base_audio(data: Dictionary = {}) -> void:
	Music = {}
	Sfx = {}
	if data.is_empty():
		data = NovaResourcePack.get_pack_data()
	
	if data.is_empty():
		push_warning("Base pack data is empty!")
		return
	
	var assets_path: String = data.get("assets-path", "")
	if assets_path.is_empty():
		push_warning("Base pack 'assets-path' is empty. Its recommended to add one for the base pack than typing every full path")
	var sfx_path: String = assets_path + data.get("sfx-path", "")
	var music_path: String = assets_path + data.get("music-path", "")
	
	var audio: Dictionary = data.get("audio")
	var sfxs: Dictionary = audio.get("sfx")
	var musics: Dictionary = audio.get("music")
	print("Loading audio pack: %s" % NovaResourcePack.BASE_PACK_ID)
	print("Loading sfx: %s" % NovaResourcePack.BASE_PACK_ID)
	load_sfx(sfxs, sfx_path)
	print("Loading music: %s" % NovaResourcePack.BASE_PACK_ID)
	load_music(musics, music_path)


func load_sfx(sfxs: Dictionary, audio_path: String) -> void:
	for sfx_id in sfxs.keys():
		var sfx_path: String = audio_path + sfxs[sfx_id]
		add_sfx(sfx_id, sfx_path)


func load_music(musics: Dictionary, audio_path: String) -> void:
	for music_id in musics.keys():
		var music_path: String = audio_path + musics[music_id]
		add_music(music_id, music_path)


func load_audio_pack(id: String, data: Dictionary = {}) -> void:
	if data.is_empty():
		data = NovaResourcePack.get_pack_data(id)
	
	if data.is_empty():
		push_warning("Pack %s data.json is empty")
		return
	
	var base_path: String = NovaResourcePack.RESOURCE_PACKS_PATH + "/%s/" % id
	var sfx_path: String = base_path + data.get("assets-path", "") + data.get("sfx-path", "")
	var music_path: String = base_path + data.get("assets-path", "") + data.get("music-path", "")
	
	var audio: Dictionary = data.get("audio")
	var sfxs: Dictionary = audio.get("sfx")
	var musics: Dictionary = audio.get("music")
	
	print("Loading audio pack: %s" % id)
	print("Loading sfx: %s" % id)
	load_sfx(sfxs, sfx_path)
	print("Loading music: %s" % id)
	load_music(musics, music_path)
