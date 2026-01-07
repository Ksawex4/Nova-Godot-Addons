extends Node

## Saves the Dictionary to a file
func save_file(file_name: String, data: Dictionary, path: String="user://") -> void:
	var data_string := JSON.stringify(data)
	
	if !path.ends_with("/"):
		path += "/"
	var file_path := path + file_name
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	var err := FileAccess.get_open_error()
	if err != OK or file == null:
		print("Failed to open file at path %s | error: %s file: %s" % [file_path, err, file])
		return
	
	file.store_string(data_string)
	file.close()


## Returns an empty Dictionary if: file doesn't exist, failed to open or the file is empty
func get_data_from_file(file_name: String, path: String="user://") -> Dictionary:
	if !path.ends_with("/"):
		path += "/"
	var file_path := path + file_name
	
	if !FileAccess.file_exists(file_path):
		print("File doesn't exist | file_path: ", file_path)
		return {}
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	var err := FileAccess.get_open_error()
	if err != OK or file == null:
		print("Failed to open file at path %s | error: %s file: %s" % [file_path, err, file])
		return {}
	
	var data_string := file.get_as_text()
	var data: Dictionary = JSON.parse_string(data_string)
	return data
