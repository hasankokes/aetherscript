extends Node

const SAVE_PATH = "user://aetherscript_save.json"
const SAVE_VERSION = 1

func save_all() -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	var _game_manager = get_node("/root/GameManager")
	var _mastery_manager = get_node("/root/MasteryManager")
	var _prestige_manager = get_node("/root/PrestigeManager")
	var _daily_manager = get_node("/root/DailyChallengeManager")

	var data = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),

		# Resources
		"resources": _player_inv.resources,

		# Hardware levels
		"hardware": _game_manager.hardware_levels,

		# Mastery XP
		"mastery_xp": _mastery_manager.get_save_data(),

		# Prestige
		"prestige_count": _game_manager.prestige_count,
		"pure_aether": _game_manager.pure_aether,
		"offline_multiplier": _game_manager.offline_multiplier,

		# Pipeline configuration
		"pipeline": _serialize_pipeline(),

		# Card inventory
		"owned_cards": _serialize_cards(),

		# Stats
		"stats": {
			"total_runs": _game_manager.total_runs,
			"best_floor": _game_manager.best_floor,
			"total_kills": _game_manager.total_kills,
		},

		"prestige_upgrades": _prestige_manager.get_save_data(),
		"daily_challenge":   _daily_manager.get_save_data(),
		"last_online_time":  _game_manager.last_online_time,
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Save file could not be opened: " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Game saved.")

func load_all() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Save file not found - starting new game.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Save file could not be read.")
		return false

	var raw = file.get_as_text()
	file.close()

	var data = JSON.parse_string(raw)
	if data == null:
		push_error("Save file corrupted - JSON parse error.")
		return false

	var _player_inv = get_node("/root/PlayerInventory")
	var _game_manager = get_node("/root/GameManager")
	var _mastery_manager = get_node("/root/MasteryManager")
	var _prestige_manager = get_node("/root/PrestigeManager")
	var _daily_manager = get_node("/root/DailyChallengeManager")

	# Resources
	if data.has("resources"):
		_player_inv.resources = data["resources"]

	# Hardware
	if data.has("hardware"):
		_game_manager.hardware_levels = data["hardware"]

	# Mastery
	if data.has("mastery_xp"):
		_mastery_manager.load_save_data(data["mastery_xp"])

	# Prestige
	_game_manager.prestige_count      = data.get("prestige_count", 0)
	_game_manager.pure_aether         = data.get("pure_aether", 0)
	_game_manager.offline_multiplier  = data.get("offline_multiplier", 1.0)

	# Stats
	if data.has("stats"):
		_game_manager.total_runs  = data["stats"].get("total_runs", 0)
		_game_manager.best_floor  = data["stats"].get("best_floor", 0)
		_game_manager.total_kills = data["stats"].get("total_kills", 0)

	# Cards
	if data.has("owned_cards"):
		_deserialize_cards(data["owned_cards"])

	# Pipeline
	if data.has("pipeline"):
		_deserialize_pipeline(data["pipeline"])

	if data.has("prestige_upgrades"):
		_prestige_manager.load_save_data(data["prestige_upgrades"])
	if data.has("daily_challenge"):
		_daily_manager.load_save_data(data["daily_challenge"])
	_game_manager.last_online_time = data.get("last_online_time", 0.0)

	print("Game loaded.")
	return true

func _serialize_pipeline() -> Dictionary:
	var _player_inv = get_node("/root/PlayerInventory")
	var result = {}
	for slot_index in _player_inv.pipeline_config:
		var card = _player_inv.pipeline_config[slot_index]
		result[str(slot_index)] = _card_to_dict(card)
	return result

func _deserialize_pipeline(data: Dictionary) -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	_player_inv.pipeline_config.clear()
	for key in data:
		var card = _dict_to_card(data[key])
		_player_inv.pipeline_config[int(key)] = card

func _serialize_cards() -> Array:
	var _player_inv = get_node("/root/PlayerInventory")
	var result = []
	for card in _player_inv.owned_cards:
		result.append(_card_to_dict(card))
	return result

func _deserialize_cards(data: Array) -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	_player_inv.owned_cards.clear()
	for card_dict in data:
		_player_inv.owned_cards.append(_dict_to_card(card_dict))

func _card_to_dict(card: CardData) -> Dictionary:
	return {
		"card_name":   card.card_name,
		"card_type":   card.card_type,
		"element":     card.element,
		"tier":        card.tier,
		"base_value":  card.base_value,
		"cooldown":    card.cooldown,
		"mana_cost":   card.mana_cost,
		"description": card.description,
		"synergy_tags": card.synergy_tags,
	}

func _dict_to_card(d: Dictionary) -> CardData:
	var card = CardData.new()
	card.card_name    = d.get("card_name",   "?")
	card.card_type    = d.get("card_type",    AetherEnums.CardType.ACTION)
	card.element      = d.get("element",      AetherEnums.ElementType.NEUTRAL)
	card.tier         = d.get("tier",         AetherEnums.CardTier.TIER_1)
	card.base_value   = d.get("base_value",   10.0)
	card.cooldown     = d.get("cooldown",     1.0)
	card.mana_cost    = d.get("mana_cost",    0)
	card.description  = d.get("description", "")
	var tags = d.get("synergy_tags", [])
	if tags is Array:
		card.synergy_tags.assign(tags)
	return card

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save deleted.")
