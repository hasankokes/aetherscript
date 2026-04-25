extends Button

const AUDIO_SETTINGS = preload("res://scenes/ui/audio_settings_panel.tscn")

func _ready() -> void:
	text = "☰"
	custom_minimum_size = Vector2(44, 44)

func _on_pressed() -> void:
	var panel = AUDIO_SETTINGS.instantiate()
	# Center it approximately
	panel.position = Vector2(80, 100)
	get_tree().root.add_child(panel)
