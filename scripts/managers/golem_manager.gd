extends Node

var active_personality: GolemPersonalityData = null
var unlocked_personalities: Array[String] = ["classic"]

# Ultimate sistemi
var ultimate_cooldowns: Dictionary = {}
const ULTIMATE_COOLDOWN: float = 60.0  # saniye

signal personality_changed(new_personality: GolemPersonalityData)
signal ultimate_activated(element: AEnums.ElementType)

func _ready() -> void:
	_load_personality("classic")
	_check_unlocks()

func _load_personality(personality_id: String) -> void:
	var path = "res://data/personalities/%s.tres" % personality_id
	if not ResourceLoader.exists(path):
		push_error("Kişilik bulunamadı: " + path)
		return
	active_personality = ResourceLoader.load(path) as GolemPersonalityData
	_apply_personality()
	personality_changed.emit(active_personality)

func _apply_personality() -> void:
	if active_personality == null:
		return
	
	var _game_manager = get_node("/root/GameManager")
	var _combat_manager = get_node("/root/CombatManager")
	var _event_bus = get_node("/root/EventBus")
	
	# HP çarpanı
	var base_hp = 100.0 + (_game_manager.hardware_levels.get("battery", 1) - 1) * 20.0
	_combat_manager.golem_stats.max_hp = base_hp * active_personality.hp_multiplier
	_combat_manager.golem_stats.current_hp = _combat_manager.golem_stats.max_hp

	# Hasar çarpanları
	_combat_manager.golem_damage_multiplier[AEnums.ElementType.FIRE] = active_personality.fire_damage_multiplier
	_combat_manager.golem_damage_multiplier[AEnums.ElementType.WATER] = active_personality.water_damage_multiplier
	_combat_manager.golem_damage_multiplier[AEnums.ElementType.EARTH] = active_personality.earth_damage_multiplier
	_combat_manager.golem_damage_multiplier[AEnums.ElementType.AIR] = active_personality.air_damage_multiplier

	# Compile hızı
	# CompileManager bu değeri kullanacak
	_event_bus.golem_hp_changed.emit(_combat_manager.golem_stats.current_hp, _combat_manager.golem_stats.max_hp)

func switch_personality(personality_id: String) -> bool:
	if not unlocked_personalities.has(personality_id):
		return false
	_load_personality(personality_id)
	get_node("/root/GameManager").active_personality_id = personality_id
	get_node("/root/SaveSystem").save_all()
	return true

func _check_unlocks() -> void:
	var _game_manager = get_node("/root/GameManager")
	var checks = [
		["aether_forge",   _check_prestige(1)],
		["stone_sentinel", _check_mastery(AEnums.ElementType.EARTH, 10)],
		["ember_wraith",   _check_mastery(AEnums.ElementType.FIRE, 15)],
		["void_runner",    _check_mastery(AEnums.ElementType.AIR, 10)],
	]
	for check in checks:
		if check[1] and not unlocked_personalities.has(check[0]):
			unlocked_personalities.append(check[0])
			print("Yeni Golem açıldı: ", check[0])

func _check_prestige(required: int) -> bool:
	return get_node("/root/GameManager").prestige_count >= required

func _check_mastery(element: AEnums.ElementType, required: int) -> bool:
	var _mastery_manager = get_node("/root/MasteryManager")
	return _mastery_manager.get_level(element) >= required

# ── Ultimate Sistemi ─────────────────────────────────

func try_activate_ultimate(element: AEnums.ElementType) -> bool:
	var _mastery_manager = get_node("/root/MasteryManager")
	var mastery_level = _mastery_manager.get_level(element)
	if mastery_level < 10:
		print("Ultimate için Mastery 10 gerekli!")
		return false

	var now = Time.get_ticks_msec() / 1000.0
	var last_use = ultimate_cooldowns.get(element, -999.0)
	if now - last_use < ULTIMATE_COOLDOWN:
		var remaining = ULTIMATE_COOLDOWN - (now - last_use)
		print("Ultimate bekleme süresi: %.0fs" % remaining)
		return false

	ultimate_cooldowns[element] = now
	_execute_ultimate(element)
	ultimate_activated.emit(element)
	return true

func _execute_ultimate(element: AEnums.ElementType) -> void:
	match element:
		AEnums.ElementType.FIRE:
			_ultimate_supernova()
		AEnums.ElementType.WATER:
			_ultimate_tidal_lock()
		AEnums.ElementType.EARTH:
			_ultimate_tectonic_shield()
		AEnums.ElementType.AIR:
			_ultimate_storm_surge()

func _ultimate_supernova() -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var _event_bus = get_node("/root/EventBus")
	if _combat_manager.current_enemy == null:
		return
	var damage = _combat_manager.golem_stats.max_hp * 3.0
	_combat_manager.current_enemy.receive_damage(damage, AEnums.ElementType.FIRE)
	print("🔥 SUPERNOVA! %.0f hasar!" % damage)
	_event_bus.synergy_triggered.emit("supernova")

func _ultimate_tidal_lock() -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var _event_bus = get_node("/root/EventBus")
	if _combat_manager.current_enemy == null:
		return
	print("💧 TIDAL LOCK! Düşman donduruldu!")
	var _freeze_timer = get_tree().create_timer(4.0)
	var state = {"tick_count": 0}
	var tick_timer = Timer.new()
	tick_timer.wait_time = 0.5
	tick_timer.timeout.connect(func():
		state.tick_count += 1
		if _combat_manager.current_enemy:
			_combat_manager.current_enemy.receive_damage(15.0, AEnums.ElementType.WATER)
		if state.tick_count >= 8:
			tick_timer.queue_free()
	)
	add_child(tick_timer)
	tick_timer.start()
	_event_bus.synergy_triggered.emit("tidal_lock")

func _ultimate_tectonic_shield() -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var _event_bus = get_node("/root/EventBus")
	print("🌍 TECTONIC SHIELD! 5sn koruma!")
	_combat_manager.damage_reduction = 0.80
	await get_tree().create_timer(5.0).timeout
	_combat_manager.damage_reduction = 0.0
	_event_bus.synergy_triggered.emit("tectonic_shield")

func _ultimate_storm_surge() -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var _event_bus = get_node("/root/EventBus")
	print("💨 STORM SURGE! 5sn hiper mod!")
	_combat_manager.crit_mode = true
	_event_bus.pipeline_speed_boost.emit(3.0)
	await get_tree().create_timer(5.0).timeout
	_combat_manager.crit_mode = false
	_event_bus.pipeline_speed_boost.emit(1.0)
	_event_bus.synergy_triggered.emit("storm_surge")

func get_save_data() -> Dictionary:
	return {
		"active_personality": active_personality.personality_id if active_personality else "classic",
		"unlocked": unlocked_personalities,
		"ultimate_cooldowns": {},
	}

func load_save_data(data: Dictionary) -> void:
	var unlocked = data.get("unlocked", ["classic"])
	unlocked_personalities.clear()
	for p in unlocked:
		unlocked_personalities.append(str(p))
	var pid = data.get("active_personality", "classic")
	_load_personality(pid)
