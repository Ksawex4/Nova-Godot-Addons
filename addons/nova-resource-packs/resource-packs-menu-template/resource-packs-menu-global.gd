extends CanvasLayer

@export var MenuPanel: PanelContainer

func _ready() -> void:
	hide_menu()


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_F1):
		show_menu()


func show_menu() -> void:
	if MenuPanel:
		MenuPanel.show()


func hide_menu() -> void:
	if MenuPanel:
		MenuPanel.hide()
