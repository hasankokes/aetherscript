extends Node

# XP thresholds for each element (XP required per level)
const XP_PER_LEVEL: int = 100
const MAX_LEVEL: int = 20

# Mastery bonuses - how much it increases per level
const DAMAGE_BONUS_PER_LEVEL: float = 0.05   # 5%/level
const SYNERGY_UNLOCK_LEVELS: Dictionary = {
	"fire_earth":  5,   
	"fire_air":    5,
	"water_earth": 5,
	"water_air":   5,
	"earth_air":   5,
	"fire_water":  10,  
}

var mastery_xp: Dictionary = {
	AetherEnums.ElementType.FIRE:  0,
	AetherEnums.ElementType.WATER: 0,
	AetherEnums.ElementType.EARTH: 0,
	AetherEnums.ElementType.AIR:   0,
}

func _ready() -> void:
	var _event_bus = get_node("/root/EventBus")
	_event_bus.mastery_xp_gained.connect(_on_xp_gained)

func _on_xp_gained(element: AetherEnums.ElementType, amount: int) -> void:
	if element == AetherEnums.ElementType.NEUTRAL:
		return

	var old_level = get_level(element)
	mastery_xp[element] = mastery_xp.get(element, 0) + amount

	var new_level = get_level(element)
	if new_level > old_level:
		_on_level_up(element, new_level)

	# Update damage bonus in CombatManager
	var _combat_manager = get_node("/root/CombatManager")
	_combat_manager.mastery_damage_bonus[element] = \
		1.0 + new_level * DAMAGE_BONUS_PER_LEVEL

func get_level(element: AetherEnums.ElementType) -> int:
	var xp = mastery_xp.get(element, 0)
	return mini(xp / XP_PER_LEVEL, MAX_LEVEL)

func get_xp_progress(element: AetherEnums.ElementType) -> float:
	var xp = mastery_xp.get(element, 0)
	var level = get_level(element)
	if level >= MAX_LEVEL:
		return 1.0
	var xp_in_level = xp - (level * XP_PER_LEVEL)
	return float(xp_in_level) / XP_PER_LEVEL

func _on_level_up(element: AetherEnums.ElementType, new_level: int) -> void:
	print("LEVEL UP! Element: %s -> Level %d" % [
		AetherEnums.ElementType.keys()[element], new_level])
	_check_synergy_unlocks()

func _check_synergy_unlocks() -> void:
	var pairs = {
		"fire_earth":  [AetherEnums.ElementType.FIRE,  AetherEnums.ElementType.EARTH],
		"fire_air":    [AetherEnums.ElementType.FIRE,  AetherEnums.ElementType.AIR],
		"water_earth": [AetherEnums.ElementType.WATER, AetherEnums.ElementType.EARTH],
		"water_air":   [AetherEnums.ElementType.WATER, AetherEnums.ElementType.AIR],
		"earth_air":   [AetherEnums.ElementType.EARTH, AetherEnums.ElementType.AIR],
		"fire_water":  [AetherEnums.ElementType.FIRE,  AetherEnums.ElementType.WATER],
	}
	for synergy_id in pairs:
		var elements = pairs[synergy_id]
		var required  = SYNERGY_UNLOCK_LEVELS[synergy_id]
		if get_level(elements[0]) >= required and \
		   get_level(elements[1]) >= required:
			_unlock_synergy_card(synergy_id)

func _unlock_synergy_card(synergy_id: String) -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	# Don't add if already unlocked
	for card in _player_inv.owned_cards:
		if card.synergy_tags.has(synergy_id):
			return

	var synergy_cards = {
		"fire_earth":  ["Magma Pulse",       AetherEnums.ElementType.FIRE,  55.0],
		"fire_air":    ["Firestorm Vortex",  AetherEnums.ElementType.FIRE,  45.0],
		"water_earth": ["Obsidian Torrent",  AetherEnums.ElementType.WATER, 40.0],
		"water_air":   ["Tempest Lens",      AetherEnums.ElementType.WATER, 35.0],
		"earth_air":   ["Dust Devil",        AetherEnums.ElementType.EARTH, 38.0],
		"fire_water":  ["Steam Engine",      AetherEnums.ElementType.FIRE,  70.0],
	}
	var data = synergy_cards.get(synergy_id)
	if data == null:
		return

	var card = CardData.new()
	card.card_name  = data[0]
	card.card_type  = AetherEnums.CardType.ACTION
	card.element    = data[1]
	card.base_value = data[2]
	card.synergy_tags = [synergy_id]
	_player_inv.add_card(card)

	var _event_bus = get_node("/root/EventBus")
	_event_bus.synergy_triggered.emit(synergy_id)
	print("SYNERGY UNLOCKED: ", data[0])

func get_save_data() -> Dictionary:
	var save = {}
	for element in mastery_xp:
		save[str(element)] = mastery_xp[element]
	return save

func load_save_data(data: Dictionary) -> void:
	for key in data:
		mastery_xp[int(key)] = data[key]
