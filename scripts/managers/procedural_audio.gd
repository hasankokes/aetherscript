extends Node

# Her element için frekans teması
const ELEMENT_FREQUENCIES = {
	AEnums.ElementType.FIRE:    440.0,  # A4 — sıcak
	AEnums.ElementType.WATER:   528.0,  # C5 — akıcı
	AEnums.ElementType.EARTH:   330.0,  # E4 — derin
	AEnums.ElementType.AIR:     660.0,  # E5 — hafif
	AEnums.ElementType.NEUTRAL: 392.0,  # G4 — nötr
}

# Ses kanalları
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _sfx_pool_size: int = 8

# Ses ayarları
var sfx_volume: float  = 0.8
var music_volume: float = 0.4
var sfx_enabled: bool  = true
var music_enabled: bool = true

func _ready() -> void:
	_init_sfx_pool()
	_init_music_player()
	_connect_signals()

func _init_sfx_pool() -> void:
	for i in range(_sfx_pool_size):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

func _init_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.volume_db = linear_to_db(music_volume)
	add_child(_music_player)

func _connect_signals() -> void:
	var _event_bus = get_node("/root/EventBus")
	if not _event_bus: return
	
	_event_bus.pipeline_card_activated.connect(_on_card_activated)
	_event_bus.enemy_damaged.connect(_on_enemy_damaged)
	_event_bus.combo_counter_changed.connect(_on_combo_changed)
	_event_bus.golem_died.connect(_on_golem_died)
	_event_bus.synergy_triggered.connect(_on_synergy_triggered)
	_event_bus.ultimate_activated.connect(_on_ultimate_activated)
	_event_bus.run_ended.connect(func(_f, _l): play_sfx_run_end())

# ── SFX Üretimi ─────────────────────────────────────

func _get_free_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	return _sfx_players[0]

func play_tone(
		frequency: float,
		duration: float,
		wave_type: String = "sine",
		volume: float = 0.6) -> void:
	if not sfx_enabled:
		return
	var player = _get_free_player()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100.0
	stream.buffer_length = duration
	player.stream = stream
	player.volume_db = linear_to_db(volume * sfx_volume)
	player.play()

	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return

	var sample_rate = 44100.0
	var total_samples = int(sample_rate * duration)
	var phase = 0.0
	var phase_inc = frequency / sample_rate

	for i in range(total_samples):
		var t = float(i) / sample_rate
		var envelope = 1.0
		# Attack (ilk %10)
		if t < duration * 0.1:
			envelope = t / (duration * 0.1)
		# Release (son %30)
		elif t > duration * 0.7:
			envelope = (duration - t) / (duration * 0.3)

		var sample = 0.0
		match wave_type:
			"sine":
				sample = sin(phase * TAU) * envelope
			"square":
				sample = (1.0 if sin(phase * TAU) > 0 else -1.0) * envelope * 0.5
			"sawtooth":
				sample = (fmod(phase, 1.0) * 2.0 - 1.0) * envelope * 0.5
			"triangle":
				sample = (abs(fmod(phase, 1.0) - 0.5) * 4.0 - 1.0) * envelope

		playback.push_frame(Vector2(sample, sample))
		phase += phase_inc

func play_chord(
		frequencies: Array,
		duration: float,
		volume: float = 0.5) -> void:
	for freq in frequencies:
		play_tone(freq, duration, "sine", volume / frequencies.size())

# ── Element Ses Temaları ─────────────────────────────

func play_card_activation(element: AEnums.ElementType) -> void:
	if not sfx_enabled:
		return
	var base_freq = ELEMENT_FREQUENCIES.get(element, 392.0)
	match element:
		AEnums.ElementType.FIRE:
			# Keskin, yükselen ses
			play_tone(base_freq,       0.08, "sawtooth", 0.5)
			play_tone(base_freq * 1.5, 0.12, "sine",     0.3)
		AEnums.ElementType.WATER:
			# Akışkan, yumuşak
			play_tone(base_freq,        0.15, "sine", 0.5)
			play_tone(base_freq * 1.25, 0.20, "sine", 0.25)
		AEnums.ElementType.EARTH:
			# Derin, kalın
			play_tone(base_freq * 0.5, 0.20, "square",   0.4)
			play_tone(base_freq,       0.10, "triangle",  0.3)
		AEnums.ElementType.AIR:
			# Hafif, yüksek
			play_tone(base_freq * 2.0, 0.10, "sine",     0.3)
			play_tone(base_freq * 2.5, 0.08, "sine",     0.2)
		_:
			play_tone(base_freq, 0.08, "sine", 0.4)

func play_sfx_hit(element: AEnums.ElementType, damage: float) -> void:
	if not sfx_enabled:
		return
	var base_freq = ELEMENT_FREQUENCIES.get(element, 392.0)
	var intensity = clampf(damage / 100.0, 0.3, 1.0)
	# Hasar büyüklüğüne göre ses şiddeti
	play_tone(base_freq * 0.5, 0.12, "square", 0.4 * intensity)

func play_sfx_combo(count: int, element: AEnums.ElementType) -> void:
	if not sfx_enabled or count < 2:
		return
	var base_freq = ELEMENT_FREQUENCIES.get(element, 392.0)
	# Combo sayısına göre yükselen nota
	var freq_mult = 1.0 + (count - 2) * 0.15
	play_tone(base_freq * freq_mult, 0.15, "sine", 0.6)
	if count >= 5:
		# Ekstra harmonik
		play_tone(base_freq * freq_mult * 1.5, 0.20, "sine", 0.4)

func play_sfx_run_end() -> void:
	if not sfx_enabled:
		return
	# Aşağı inen melodi
	var notes = [440.0, 392.0, 349.0, 330.0]
	for i in range(notes.size()):
		await get_tree().create_timer(i * 0.15).timeout
		play_tone(notes[i], 0.2, "sine", 0.5)

func play_sfx_level_up() -> void:
	if not sfx_enabled:
		return
	# Yukarı çıkan arpej
	var notes = [330.0, 392.0, 440.0, 523.0, 659.0]
	for i in range(notes.size()):
		await get_tree().create_timer(i * 0.08).timeout
		play_tone(notes[i], 0.15, "sine", 0.55)

func play_sfx_compile_complete() -> void:
	if not sfx_enabled:
		return
	play_chord([523.0, 659.0, 784.0], 0.4, 0.6)
	await get_tree().create_timer(0.3).timeout
	play_chord([659.0, 784.0, 988.0], 0.5, 0.5)

func play_sfx_prestige() -> void:
	if not sfx_enabled:
		return
	# Uzun, tatmin edici yükselen akor
	var freqs = [220.0, 277.0, 330.0, 440.0, 554.0, 659.0, 880.0]
	for i in range(freqs.size()):
		await get_tree().create_timer(i * 0.1).timeout
		play_tone(freqs[i], 0.4, "sine", 0.3 + i * 0.05)

func play_sfx_ultimate(element: AEnums.ElementType) -> void:
	if not sfx_enabled:
		return
	match element:
		AEnums.ElementType.FIRE:
			# Yükselen dramatik akor
			play_chord([220.0, 330.0, 440.0, 660.0], 0.8, 0.7)
		AEnums.ElementType.WATER:
			# Dalgalı harmonik
			play_chord([528.0, 660.0, 792.0], 1.0, 0.6)
		AEnums.ElementType.EARTH:
			# Derin gümbürtü
			play_chord([82.0, 110.0, 165.0], 1.2, 0.7)
		AEnums.ElementType.AIR:
			# Yüksek frekans patlaması
			play_chord([880.0, 1100.0, 1320.0], 0.6, 0.5)

func play_sfx_ui_click() -> void:
	play_tone(660.0, 0.05, "sine", 0.3)

func play_sfx_ui_error() -> void:
	play_tone(200.0, 0.15, "square", 0.4)

func play_sfx_synergy_unlock() -> void:
	if not sfx_enabled:
		return
	play_chord([440.0, 550.0, 660.0, 880.0], 0.6, 0.65)
	await get_tree().create_timer(0.5).timeout
	play_chord([550.0, 660.0, 880.0, 1100.0], 0.7, 0.55)

# ── Sinyal Bağlantıları ──────────────────────────────

func _on_card_activated(card: CardData, _index: int) -> void:
	play_card_activation(card.element)

func _on_enemy_damaged(damage: float, element: AEnums.ElementType) -> void:
	play_sfx_hit(element, damage)

func _on_combo_changed(count: int, element: AEnums.ElementType) -> void:
	play_sfx_combo(count, element)

func _on_golem_died() -> void:
	play_sfx_run_end()

func _on_synergy_triggered(synergy_id: String) -> void:
	match synergy_id:
		"supernova", "tidal_lock", "tectonic_shield", "storm_surge":
			pass  # Ultimate sesleri ayrı
		_:
			play_sfx_synergy_unlock()

func _on_ultimate_activated(element: AEnums.ElementType) -> void:
	play_sfx_ultimate(element)
