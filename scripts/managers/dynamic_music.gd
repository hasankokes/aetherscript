extends Node

# Pipeline kompozisyonuna göre müzik durumu
var current_dominant_element: AEnums.ElementType = AEnums.ElementType.NEUTRAL
var current_bpm: float = 80.0
var is_combat_mode: bool = false

# Müzik katmanları için AudioStreamPlayer'lar
var _base_player:    AudioStreamPlayer = null
var _melody_player:  AudioStreamPlayer = null
var _rhythm_player:  AudioStreamPlayer = null

# Metronom sistemi
var _beat_timer: Timer = null
var _beat_count: int = 0
var _bar_length: int = 4     # 4/4 zaman

signal beat_triggered(beat_number: int)
signal bar_completed()

func _ready() -> void:
	_init_players()
	_init_beat_timer()
	
	var _event_bus = get_node("/root/EventBus")
	if _event_bus:
		_event_bus.pipeline_card_activated.connect(_on_card_activated)

func _init_players() -> void:
	# Add 3 players for different layers
	for i in range(3):
		var p = AudioStreamPlayer.new()
		p.bus = "Music"
		add_child(p)
	
	_base_player   = get_child(0)
	_melody_player = get_child(1)
	_rhythm_player = get_child(2)

func _init_beat_timer() -> void:
	_beat_timer = Timer.new()
	_beat_timer.wait_time = 60.0 / current_bpm
	_beat_timer.autostart = false
	_beat_timer.timeout.connect(_on_beat)
	add_child(_beat_timer)

func start_combat_music(dominant_element: AEnums.ElementType) -> void:
	is_combat_mode = true
	current_dominant_element = dominant_element
	_update_bpm_for_element(dominant_element)
	_beat_timer.wait_time = 60.0 / current_bpm
	_beat_timer.start()

func stop_music() -> void:
	is_combat_mode = false
	_beat_timer.stop()
	_beat_count = 0

func _update_bpm_for_element(element: AEnums.ElementType) -> void:
	match element:
		AEnums.ElementType.FIRE:
			current_bpm = 140.0   # Hızlı, agresif
		AEnums.ElementType.WATER:
			current_bpm = 70.0    # Yavaş, ambient
		AEnums.ElementType.EARTH:
			current_bpm = 90.0    # Kararlı, ağır
		AEnums.ElementType.AIR:
			current_bpm = 160.0   # Çok hızlı
		_:
			current_bpm = 100.0   # Nötr

func _on_beat() -> void:
	_beat_count += 1
	beat_triggered.emit(_beat_count)

	# Her element için farklı ritim deseni çal
	_play_beat_sound()

	# Ölçü tamamlandı mı?
	if _beat_count % _bar_length == 0:
		bar_completed.emit()
		_play_bar_accent()

func _play_beat_sound() -> void:
	var _proc_audio = get_node("/root/ProceduralAudio")
	if not _proc_audio or not _proc_audio.sfx_enabled:
		return
		
	var beat_in_bar = _beat_count % _bar_length

	match current_dominant_element:
		AEnums.ElementType.FIRE:
			# Sert ritim
			if beat_in_bar == 0:
				_proc_audio.play_tone(110.0, 0.05, "square", 0.25)
			elif beat_in_bar == 2:
				_proc_audio.play_tone(82.0, 0.05, "square", 0.20)
		AEnums.ElementType.WATER:
			# Yumuşak nabız
			if beat_in_bar == 0:
				_proc_audio.play_tone(220.0, 0.12, "sine", 0.15)
		AEnums.ElementType.EARTH:
			# Derin atış
			if beat_in_bar == 0 or beat_in_bar == 2:
				_proc_audio.play_tone(55.0, 0.15, "square", 0.25)
		AEnums.ElementType.AIR:
			# Hızlı tikling
			_proc_audio.play_tone(880.0, 0.03, "sine", 0.10)
		_:
			if beat_in_bar == 0:
				_proc_audio.play_tone(165.0, 0.08, "sine", 0.20)

func _play_bar_accent() -> void:
	var _proc_audio = get_node("/root/ProceduralAudio")
	if not _proc_audio or not _proc_audio.sfx_enabled:
		return
		
	# Her ölçü sonunda küçük melodik vurgu
	var base_freq = _proc_audio.ELEMENT_FREQUENCIES.get(current_dominant_element, 392.0)
	_proc_audio.play_tone(base_freq, 0.10, "sine", 0.18)

func _on_card_activated(card: CardData, _index: int) -> void:
	if not is_combat_mode:
		return
	# Dominant elementi güncelle
	if card.element != AEnums.ElementType.NEUTRAL:
		if card.element != current_dominant_element:
			current_dominant_element = card.element
			_update_bpm_for_element(card.element)
			_beat_timer.wait_time = 60.0 / current_bpm

func switch_to_lab_music() -> void:
	stop_music()
	is_combat_mode = false
	# Laboratuvar için sakin ambient başlat
	_start_lab_ambient()

func _start_lab_ambient() -> void:
	# Yavaş, tekrarlayan ambient döngüsü
	_beat_timer.wait_time = 60.0 / 60.0   # 60 BPM
	_beat_timer.start()
	current_dominant_element = AEnums.ElementType.NEUTRAL
