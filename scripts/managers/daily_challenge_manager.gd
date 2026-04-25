extends Node

# Mevcut günlük zorluk
var current_challenge: Dictionary = {}
var challenge_completed_today: bool = false
var last_challenge_date: String = ""

const CHALLENGE_POOL = [
	{
		"id": "only_fire",
		"title": "🔥 Saf Alev",
		"description": "Yalnızca Ateş kartları kullan.",
		"restriction": "only_element_fire",
		"reward": {"aether_shard": 3, "crystal": 10},
		"bonus_xp_element": AEnums.ElementType.FIRE,
		"bonus_xp": 50,
	},
	{
		"id": "only_water",
		"title": "💧 Saf Dalga",
		"description": "Yalnızca Su kartları kullan.",
		"restriction": "only_element_water",
		"reward": {"aether_shard": 3, "crystal": 10},
		"bonus_xp_element": AEnums.ElementType.WATER,
		"bonus_xp": 50,
	},
	{
		"id": "max_6_slots",
		"title": "🧠 Kısıtlı Bellek",
		"description": "Pipeline maksimum 6 slot kullanabilir.",
		"restriction": "max_slots_6",
		"reward": {"aether_shard": 4, "rare_metal": 2},
		"bonus_xp_element": AEnums.ElementType.NEUTRAL,
		"bonus_xp": 0,
	},
	{
		"id": "no_modifier",
		"title": "⚡ Ham Güç",
		"description": "Modifier kartlar kullanılamaz.",
		"restriction": "no_card_type_modifier",
		"reward": {"aether_shard": 5, "iron_ore": 20},
		"bonus_xp_element": AEnums.ElementType.NEUTRAL,
		"bonus_xp": 0,
	},
	{
		"id": "speedrun",
		"title": "⏱️ Hız Koşusu",
		"description": "10 katı 3 dakikada geç.",
		"restriction": "time_limit_180",
		"reward": {"aether_shard": 6, "crystal": 15},
		"bonus_xp_element": AEnums.ElementType.AIR,
		"bonus_xp": 30,
	},
	{
		"id": "no_heal",
		"title": "☠️ Ölüm Yürüyüşü",
		"description": "Hiç iyileşme kartı kullanılamaz.",
		"restriction": "no_heal",
		"reward": {"aether_shard": 8, "rare_metal": 3},
		"bonus_xp_element": AEnums.ElementType.NEUTRAL,
		"bonus_xp": 0,
	},
	{
		"id": "earth_mastery",
		"title": "🌍 Toprak Ustası",
		"description": "Yalnızca Toprak kartları, ama Mastery bonusu 3x.",
		"restriction": "only_element_earth",
		"reward": {"aether_shard": 4, "organic_core": 5},
		"bonus_xp_element": AEnums.ElementType.EARTH,
		"bonus_xp": 80,
	},
]

func _ready() -> void:
	_update_daily_challenge()

func _update_daily_challenge() -> void:
	var today = Time.get_date_string_from_system()
	if last_challenge_date == today:
		return   # Bugün zaten belirlendi

	last_challenge_date = today
	challenge_completed_today = false

	# Tarihe göre deterministik seçim (aynı gün herkes aynı zorluğu görür)
	var date_hash = today.hash()
	var index = abs(date_hash) % CHALLENGE_POOL.size()
	current_challenge = CHALLENGE_POOL[index]

func get_today_challenge() -> Dictionary:
	return current_challenge

func complete_challenge() -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	var _event_bus = get_node("/root/EventBus")
	var _save_system = get_node("/root/SaveSystem")

	if challenge_completed_today:
		return
	challenge_completed_today = true

	# Ödülleri ver
	for resource_id in current_challenge["reward"]:
		_player_inv.add_resource(
			resource_id,
			current_challenge["reward"][resource_id])

	# Bonus XP
	var bonus_el = current_challenge.get(
		"bonus_xp_element", AEnums.ElementType.NEUTRAL)
	var bonus_xp = current_challenge.get("bonus_xp", 0)
	if bonus_xp > 0:
		_event_bus.mastery_xp_gained.emit(bonus_el, bonus_xp)

	if _save_system:
		_save_system.save_all()

func apply_restriction(pipeline_bar: PipelineBar) -> void:
	var _game_manager = get_node("/root/GameManager")
	var restriction = current_challenge.get("restriction", "")
	match restriction:
		"max_slots_6":
			pipeline_bar.build_pipeline(
				mini(6, _game_manager.get_pipeline_slot_count()))
		_:
			pass  # Diğer kısıtlamalar CombatManager'da uygulanır

func is_card_allowed(card: CardData) -> bool:
	var restriction = current_challenge.get("restriction", "")
	match restriction:
		"only_element_fire":
			return card.element == AEnums.ElementType.FIRE or \
				   card.element == AEnums.ElementType.NEUTRAL
		"only_element_water":
			return card.element == AEnums.ElementType.WATER or \
				   card.element == AEnums.ElementType.NEUTRAL
		"only_element_earth":
			return card.element == AEnums.ElementType.EARTH or \
				   card.element == AEnums.ElementType.NEUTRAL
		"no_card_type_modifier":
			return card.card_type != AEnums.CardType.MODIFIER
		"no_heal":
			return card.card_type != AEnums.CardType.LOGIC
		_:
			return true

func get_save_data() -> Dictionary:
	return {
		"last_date": last_challenge_date,
		"completed": challenge_completed_today,
	}

func load_save_data(data: Dictionary) -> void:
	last_challenge_date       = data.get("last_date", "")
	challenge_completed_today = data.get("completed", false)
	_update_daily_challenge()
