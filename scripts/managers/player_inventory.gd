extends Node

# Oyuncunun sahip olduğu tüm kartlar
var owned_cards: Array[CardData] = []

# Aktif pipeline konfigürasyonu (slot_index → CardData)
var pipeline_config: Dictionary = {}

# Hammadde envanteri
var resources: Dictionary = {
	"iron_ore": 50,
	"crystal": 20,
	"aether_shard": 5,
	"rare_metal": 0,
	"organic_core": 10,
}

func add_card(card: CardData) -> void:
	owned_cards.append(card)

func remove_card_from_pipeline(slot_index: int) -> void:
	pipeline_config.erase(slot_index)

func set_card_in_pipeline(slot_index: int, card: CardData) -> void:
	pipeline_config[slot_index] = card

func get_pipeline_cards() -> Dictionary:
	return pipeline_config

func has_resource(resource_id: String, amount: int) -> bool:
	return resources.get(resource_id, 0) >= amount

func spend_resource(resource_id: String, amount: int) -> bool:
	if not has_resource(resource_id, amount):
		return false
	resources[resource_id] -= amount
	return true

func add_resource(resource_id: String, amount: int) -> void:
	resources[resource_id] = resources.get(resource_id, 0) + amount

func save() -> void:
	var _game_manager = get_node("/root/GameManager")
	var save_data = {
		"resources": resources,
		"pipeline_config": {},
		"hardware": _game_manager.hardware_levels,
		"mastery": _game_manager.mastery_levels,
	}
	for slot_index in pipeline_config:
		var card = pipeline_config[slot_index]
		save_data["pipeline_config"][str(slot_index)] = {
			"card_name": card.card_name,
			"element": card.element,
			"card_type": card.card_type,
			"base_value": card.base_value,
			"tier": card.tier,
		}
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_save() -> void:
	if not FileAccess.file_exists("user://save_data.json"):
		return
	var file = FileAccess.open("user://save_data.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return
	var _game_manager = get_node("/root/GameManager")
	resources = data.get("resources", resources)
	_game_manager.hardware_levels = data.get("hardware", _game_manager.hardware_levels)
	_game_manager.mastery_levels  = data.get("mastery",  _game_manager.mastery_levels)
