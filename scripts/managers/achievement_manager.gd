extends Node

signal achievement_unlocked(achievement: AchievementData)

var unlocked_ids: Array[String] = []

const ACHIEVEMENTS = [
	{
		"id": "first_kill",
		"name": "İlk Kan",
		"desc": "İlk düşmanını öldür.",
		"emoji": "⚔️",
		"reward_aether": 1,
		"condition": "total_kills",
		"value": 1.0,
		"hidden": false,
	},
	{
		"id": "floor_10",
		"name": "Harabenin Ötesi",
		"desc": "Kat 10'a ulaş.",
		"emoji": "🏚️",
		"reward_aether": 2,
		"condition": "best_floor",
		"value": 10.0,
		"hidden": false,
	},
	{
		"id": "floor_20",
		"name": "Kristal Kaşif",
		"desc": "Kat 20'ye ulaş.",
		"emoji": "💎",
		"reward_aether": 5,
		"condition": "best_floor",
		"value": 20.0,
		"hidden": false,
	},
	{
		"id": "floor_30",
		"name": "Boşluk Yolcusu",
		"desc": "Kat 30'a ulaş.",
		"emoji": "🌌",
		"reward_aether": 10,
		"condition": "best_floor",
		"value": 30.0,
		"hidden": false,
	},
	{
		"id": "mastery_fire_10",
		"name": "Ateşin Ustası",
		"desc": "Ateş Mastery 10. seviyeye ulaş.",
		"emoji": "🔥",
		"reward_aether": 3,
		"condition": "mastery_fire",
		"value": 10.0,
		"hidden": false,
	},
	{
		"id": "mastery_water_10",
		"name": "Suyun Efendisi",
		"desc": "Su Mastery 10. seviyeye ulaş.",
		"emoji": "💧",
		"reward_aether": 3,
		"condition": "mastery_water",
		"value": 10.0,
		"hidden": false,
	},
	{
		"id": "mastery_earth_10",
		"name": "Toprağın Bekçisi",
		"desc": "Toprak Mastery 10. seviyeye ulaş.",
		"emoji": "🌍",
		"reward_aether": 3,
		"condition": "mastery_earth",
		"value": 10.0,
		"hidden": false,
	},
	{
		"id": "mastery_air_10",
		"name": "Rüzgarın Ruhu",
		"desc": "Hava Mastery 10. seviyeye ulaş.",
		"emoji": "💨",
		"reward_aether": 3,
		"condition": "mastery_air",
		"value": 10.0,
		"hidden": false,
	},
	{
		"id": "first_synergy",
		"name": "Elementel Uyum",
		"desc": "İlk sinerji kartını aç.",
		"emoji": "✨",
		"reward_aether": 5,
		"condition": "synergy_count",
		"value": 1.0,
		"hidden": false,
	},
	{
		"id": "all_synergies",
		"name": "Tam Uyum",
		"desc": "Tüm sinerji kartlarını aç.",
		"emoji": "🌟",
		"reward_aether": 20,
		"condition": "synergy_count",
		"value": 6.0,
		"hidden": false,
	},
	{
		"id": "first_prestige",
		"name": "Büyük Sentez",
		"desc": "İlk prestige'i tamamla.",
		"emoji": "⚗️",
		"reward_aether": 10,
		"condition": "prestige_count",
		"value": 1.0,
		"hidden": false,
	},
	{
		"id": "prestige_3",
		"name": "Saf Aether",
		"desc": "3. prestige'i tamamla.",
		"emoji": "💫",
		"reward_aether": 25,
		"condition": "prestige_count",
		"value": 3.0,
		"hidden": false,
	},
	{
		"id": "first_tier2",
		"name": "Optimize Edilmiş",
		"desc": "İlk kartı Tier 2'ye compile et.",
		"emoji": "⬆️",
		"reward_aether": 2,
		"condition": "tier2_count",
		"value": 1.0,
		"hidden": false,
	},
	{
		"id": "first_tier3",
		"name": "Tam Derleme",
		"desc": "İlk kartı Tier 3'e compile et.",
		"emoji": "💜",
		"reward_aether": 8,
		"condition": "tier3_count",
		"value": 1.0,
		"hidden": false,
	},
	{
		"id": "combo_5",
		"name": "Ritim Ustası",
		"desc": "Tek turda 5x combo yap.",
		"emoji": "🎵",
		"reward_aether": 3,
		"condition": "max_combo",
		"value": 5.0,
		"hidden": false,
	},
	{
		"id": "combo_10",
		"name": "Pipeline Senfoni",
		"desc": "Tek turda 10x combo yap.",
		"emoji": "🎼",
		"reward_aether": 8,
		"condition": "max_combo",
		"value": 10.0,
		"hidden": true,
	},
	{
		"id": "first_ultimate",
		"name": "Limit Aşımı",
		"desc": "İlk Ultimate'ı aktifleştir.",
		"emoji": "⚡",
		"reward_aether": 5,
		"condition": "ultimate_count",
		"value": 1.0,
		"hidden": false,
	},
	{
		"id": "all_ultimates",
		"name": "Dört Element",
		"desc": "Tüm 4 Ultimate'ı kullan.",
		"emoji": "🌈",
		"reward_aether": 15,
		"condition": "ultimate_elements",
		"value": 4.0,
		"hidden": false,
	},
	{
		"id": "speedrun",
		"name": "Işık Hızı",
		"desc": "Kat 10'u 2 dakikada geç.",
		"emoji": "⚡",
		"reward_aether": 15,
		"condition": "floor10_time",
		"value": 120.0,
		"hidden": true,
	},
	{
		"id": "corruption_clear",
		"name": "Kaos İçinden",
		"desc": "Corruption Mode'da Kat 10'a ulaş.",
		"emoji": "☠️",
		"reward_aether": 30,
		"condition": "corruption_floor",
		"value": 10.0,
		"hidden": true,
	},
]

var stats: Dictionary = {
	"total_kills":       0,
	"best_floor":        0,
	"prestige_count":    0,
	"synergy_count":     0,
	"tier2_count":       0,
	"tier3_count":       0,
	"max_combo":         0,
	"ultimate_count":    0,
	"ultimate_elements": [],
	"floor10_time":      9999.0,
	"corruption_floor":  0,
	"mastery_fire":      0,
	"mastery_water":     0,
	"mastery_earth":     0,
	"mastery_air":       0,
	"total_runs":        0,
}

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	var eb = get_node("/root/EventBus")
	var cm = get_node("/root/CompileManager")
	eb.enemy_defeated.connect(_on_enemy_defeated)
	eb.combo_counter_changed.connect(_on_combo_changed)
	eb.synergy_triggered.connect(_on_synergy_triggered)
	eb.ultimate_activated.connect(_on_ultimate_used)
	eb.mastery_xp_gained.connect(_on_mastery_gained)
	cm.compile_completed.connect(_on_compile_completed)

func _on_enemy_defeated(_enemy_data: EnemyData) -> void:
	stats["total_kills"] += 1
	check_achievements()

func _check_kill_count() -> void:
	var gm = get_node("/root/GameManager")
	stats["total_kills"] = gm.total_kills
	check_achievements()

func _on_combo_changed(count: int, _element: AEnums.ElementType) -> void:
	if count > stats["max_combo"]:
		stats["max_combo"] = count
		check_achievements()

func _on_synergy_triggered(_id: String) -> void:
	var pi = get_node("/root/PlayerInventory")
	var count = 0
	for card in pi.owned_cards:
		if not card.synergy_tags.is_empty():
			count += 1
	stats["synergy_count"] = count
	check_achievements()

func _on_ultimate_used(element: AEnums.ElementType) -> void:
	stats["ultimate_count"] += 1
	if not stats["ultimate_elements"].has(element):
		stats["ultimate_elements"].append(element)
	check_achievements()

func _on_mastery_gained(element: AEnums.ElementType, _amount: int) -> void:
	var mm = get_node("/root/MasteryManager")
	match element:
		AEnums.ElementType.FIRE:
			stats["mastery_fire"] = mm.get_level(element)
		AEnums.ElementType.WATER:
			stats["mastery_water"] = mm.get_level(element)
		AEnums.ElementType.EARTH:
			stats["mastery_earth"] = mm.get_level(element)
		AEnums.ElementType.AIR:
			stats["mastery_air"] = mm.get_level(element)
	check_achievements()

func _on_compile_completed(card: CardData) -> void:
	match card.tier:
		AEnums.CardTier.TIER_2:
			stats["tier2_count"] += 1
		AEnums.CardTier.TIER_3:
			stats["tier3_count"] += 1
	check_achievements()

func update_run_stats(floor_reached: int, run_time: float) -> void:
	var gm = get_node("/root/GameManager")
	var pm = get_node("/root/PrestigeManager")
	
	if floor_reached > stats["best_floor"]:
		stats["best_floor"] = floor_reached
	stats["prestige_count"] = gm.prestige_count
	stats["total_runs"]     = gm.total_runs

	if floor_reached >= 10 and run_time < stats["floor10_time"]:
		stats["floor10_time"] = run_time

	if pm._has_upgrade("corruption_mode") and floor_reached > stats["corruption_floor"]:
		stats["corruption_floor"] = floor_reached

	check_achievements()

func check_achievements() -> void:
	for ach in ACHIEVEMENTS:
		if unlocked_ids.has(ach["id"]):
			continue
		if _evaluate_condition(ach):
			_unlock_achievement(ach)

func _evaluate_condition(ach: Dictionary) -> bool:
	var condition = ach["condition"]
	var value     = ach["value"]
	match condition:
		"total_kills":
			return stats["total_kills"] >= value
		"best_floor":
			return stats["best_floor"] >= value
		"prestige_count":
			return stats["prestige_count"] >= value
		"synergy_count":
			return stats["synergy_count"] >= value
		"tier2_count":
			return stats["tier2_count"] >= value
		"tier3_count":
			return stats["tier3_count"] >= value
		"max_combo":
			return stats["max_combo"] >= value
		"ultimate_count":
			return stats["ultimate_count"] >= value
		"ultimate_elements":
			return stats["ultimate_elements"].size() >= value
		"floor10_time":
			return stats["floor10_time"] <= value
		"corruption_floor":
			return stats["corruption_floor"] >= value
		"mastery_fire":
			return stats["mastery_fire"] >= value
		"mastery_water":
			return stats["mastery_water"] >= value
		"mastery_earth":
			return stats["mastery_earth"] >= value
		"mastery_air":
			return stats["mastery_air"] >= value
	return false

func _unlock_achievement(ach: Dictionary) -> void:
	unlocked_ids.append(ach["id"])
	var gm = get_node("/root/GameManager")
	var ss = get_node("/root/SaveSystem")
	
	gm.pure_aether += ach.get("reward_aether", 0)

	var data = AchievementData.new()
	data.achievement_id = ach["id"]
	data.display_name   = ach["name"]
	data.description    = ach["desc"]
	data.emoji          = ach["emoji"]
	data.reward_aether  = ach.get("reward_aether", 0)
	achievement_unlocked.emit(data)

	ss.save_all()
	print("🏆 Başarım: %s — %s" % [ach["emoji"], ach["name"]])

func get_save_data() -> Dictionary:
	return {
		"unlocked": unlocked_ids,
		"stats":    stats,
	}

func load_save_data(data: Dictionary) -> void:
	var unlocked = data.get("unlocked", [])
	unlocked_ids.clear()
	for id in unlocked:
		unlocked_ids.append(str(id))
	var saved_stats = data.get("stats", {})
	for key in saved_stats:
		stats[key] = saved_stats[key]
