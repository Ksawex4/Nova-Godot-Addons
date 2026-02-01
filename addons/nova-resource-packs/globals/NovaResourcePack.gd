extends Node

var ResourcePacks: PackedStringArray = [BASE_PACK_ID]
var ActiveResourcePacks: PackedStringArray = [BASE_PACK_ID]
const BASE_PACK_ID = "base"
const BASE_PACK_DATA_PATH = "res://assets/data.json" # Path to data.json of the default resource pack
const RESOURCE_PACKS_PATH = "user://resource-packs"
const RESOURCE_PACK_DATA_PATH = RESOURCE_PACKS_PATH + "/%s/data.json"

func _ready() -> void:
	load_base_assets()
	load_resource_pack_ids()


func load_base_assets() -> void:
	print("Loading pack: %s" % BASE_PACK_ID)
	var base_data: Dictionary = get_pack_data()
	NovaTranslation.load_base_translations(base_data)
	NovaTexture.load_base_textures(base_data)
	NovaAnimation.load_base_animations(base_data)
	NovaAudio.load_base_audio(base_data)
	NovaFont.load_base_fonts(base_data)
	print("============ Loaded %s ==============" % BASE_PACK_ID)


func load_resource_pack_ids() -> void:
	var packs: PackedStringArray
	
	if !DirAccess.dir_exists_absolute(RESOURCE_PACKS_PATH):
		DirAccess.make_dir_recursive_absolute(RESOURCE_PACKS_PATH)
	
	var directories: PackedStringArray = DirAccess.get_directories_at(RESOURCE_PACKS_PATH)
	packs.append_array(directories)
	var verified_packs: PackedStringArray = [BASE_PACK_ID]
	for x in packs:
		if x == BASE_PACK_ID:
			push_warning("User pack id %s is the same as base pack id, skipping" % x)
			continue
		
		if verified_packs.has(x):
			push_warning("User pack id %s already exists in resource packs, change pack folder name" % x)
			continue
		
		verified_packs.append(x)
	ResourcePacks = verified_packs


## Returns empty on fail 
func get_pack_data(id: String = BASE_PACK_ID) -> Dictionary:
	var pack_data_path: String = RESOURCE_PACK_DATA_PATH % id
	if id == BASE_PACK_ID:
		pack_data_path = BASE_PACK_DATA_PATH
	if !FileAccess.file_exists(pack_data_path):
		push_warning("data.json doesn't exist for id: %s path: %s " % [id, pack_data_path])
		return {}
	
	var file: FileAccess = FileAccess.open(pack_data_path, FileAccess.READ)
	var err: Error = FileAccess.get_open_error()
	if err != OK:
		push_warning("Failed to open data.json at %s got error: %s" % [pack_data_path, err])
		return {}
	
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	return data


func activate_resource_pack(id: String) -> void:
	load_resource_pack_ids()
	if ResourcePacks.has(id) and !ActiveResourcePacks.has(id):
		ActiveResourcePacks.append(id)


func disable_resource_pack(id: String) -> void:
	if ActiveResourcePacks.has(id) and id != BASE_PACK_ID:
		ActiveResourcePacks.erase(id)
	
	if !ResourcePacks.has(id):
		ResourcePacks.erase(id)


func return_save_data() -> Dictionary:
	return {
		"ActiveResourcePacks": ActiveResourcePacks
	}


func load_save_data(data: Dictionary) -> void:
	ActiveResourcePacks = data.get("ActiveResourcePacks", [BASE_PACK_ID])
	load_active_resource_packs()


func load_active_resource_packs() -> void:
	print("Loading packs: ",ActiveResourcePacks)
	load_base_assets()
	
	for id in ActiveResourcePacks:
		if id == BASE_PACK_ID:
			continue
		print("Loading pack: %s" % id)
		var pack_data: Dictionary = get_pack_data(id)
		
		NovaTranslation.load_translation_pack(id, pack_data)
		NovaTexture.load_texture_pack(id, pack_data)
		NovaAnimation.load_animation_pack(id, pack_data)
		NovaAudio.load_audio_pack(id, pack_data)
		NovaFont.load_font_pack(id, pack_data)
		print("============ Loaded pack %s ==============" % id)
	
	NovaTexture.ReloadTexture.emit()
	NovaAnimation.ReloadAnimation.emit()
	NovaAudio.ReloadSfx.emit()
	NovaAudio.ReloadMusic.emit()
	NovaFont.ReloadFont.emit()
