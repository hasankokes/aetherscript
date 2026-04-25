extends PanelContainer

@onready var sfx_slider:    HSlider     = $VBoxContainer/SFXRow/SFXSlider
@onready var sfx_toggle:    CheckButton = $VBoxContainer/SFXRow/SFXToggle
@onready var music_slider:  HSlider     = $VBoxContainer/MusicRow/MusicSlider
@onready var music_toggle:  CheckButton = $VBoxContainer/MusicRow/MusicToggle

func _ready() -> void:
	var _proc_audio = get_node("/root/ProceduralAudio")
	if not _proc_audio: return
	
	sfx_slider.value   = _proc_audio.sfx_volume
	music_slider.value = _proc_audio.music_volume
	sfx_toggle.button_pressed   = _proc_audio.sfx_enabled
	music_toggle.button_pressed = _proc_audio.music_enabled
	
	sfx_toggle.text = "Açık" if _proc_audio.sfx_enabled else "Kapalı"
	music_toggle.text = "Açık" if _proc_audio.music_enabled else "Kapalı"

	sfx_slider.value_changed.connect(func(v):
		_proc_audio.sfx_volume = v)
	music_slider.value_changed.connect(func(v):
		_proc_audio.music_volume = v)
	sfx_toggle.toggled.connect(func(on):
		_proc_audio.sfx_enabled = on
		sfx_toggle.text = "Açık" if on else "Kapalı")
	music_toggle.toggled.connect(func(on):
		_proc_audio.music_enabled = on
		music_toggle.text = "Açık" if on else "Kapalı")
	
	$VBoxContainer/CloseButton.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed() -> void:
	_save_audio_settings()
	queue_free()

func _save_audio_settings() -> void:
	var _proc_audio = get_node("/root/ProceduralAudio")
	if not _proc_audio: return
	
	var config = ConfigFile.new()
	config.set_value("audio", "sfx_volume", _proc_audio.sfx_volume)
	config.set_value("audio", "sfx_enabled", _proc_audio.sfx_enabled)
	config.set_value("audio", "music_volume", _proc_audio.music_volume)
	config.set_value("audio", "music_enabled", _proc_audio.music_enabled)
	config.save("user://audio_settings.cfg")
