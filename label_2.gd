extends Label


func _ready() -> void:
	NovaFont.add_font("main", "res://assets/fonts/main.ttf")
	if label_settings == null:
		label_settings = LabelSettings.new()
	label_settings.font = NovaFont.get_font("main")
