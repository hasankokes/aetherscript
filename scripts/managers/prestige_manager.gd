extends Node

# Prestige için gereken minimum kat (her prestijde artar)
const BASE_PRESTIGE_FLOOR: int = 25
const PRESTIGE_FLOOR_SCALING: float = 1.3

# Saf Aether harcama tablosu
const AETHER_UPGRADES = {
	"offline_x5": {
		"display": "⏰ Offline Kazanç x5",
		"description": "Offline süreyi 5 kat verimli sayar.",
		"cost": 10,
		"max_purchases": 1,
	},
	"dual_element_start": {
		"display": "⚗️ Çift Element Başlangıcı",
		"description": "Prestige sonrası 2 element Mastery 5'ten başlar.",
		"cost": 15,
		"max_purchases": 1,
	},
	"corruption_mode": {
		"display": "☠️ Corruption Mode",
		"description": "Düşmanlar 2x güçlü, ganimet 4x.",
		"cost": 20,
		"max_purchases": 1,
	},
	"aether_resonance": {
		"display": "✨ Aether Resonance",
		"description": "Tüm sinerji açılma eşiklerini -%25 düşürür.",
		"cost": 12,
		"max_purchases": 1,
	},
	"ghost_pipeline": {
		"display": "👻 Ghost Pipeline",
		"description": "Önceki turun pipeline'ını hayalet olarak gösterir.",
		"cost": 8,
		"max_purchases": 1,
	},
	"extra_slot": {
		"display": "🧠 Ekstra Pipeline Slot",
		"description": "Prestige sonrası 1 ek slot kalıcı olarak açılır.",
		"cost": 18,
		"max_purchases": 3,
	},
}

var purchased_upgrades: Dictionary = {}   # upgrade_id → kaç kez satın alındı

func get_prestige_floor_requirement() -> int:
	var _game_manager = get_node("/root/GameManager")
	return int(BASE_PRESTIGE_FLOOR * \
		pow(PRESTIGE_FLOOR_SCALING, _game_manager.prestige_count))

func can_prestige(current_floor: int) -> bool:
	return current_floor >= get_prestige_floor_requirement()

func calculate_aether_gain() -> int:
	var _game_manager = get_node("/root/GameManager")
	var _mastery_manager = get_node("/root/MasteryManager")
	# Temel kazanç + bonus
	var base = 5 + _game_manager.prestige_count * 2
	var mastery_bonus = 0
	for element in _game_manager.mastery_levels:
		mastery_bonus += _mastery_manager.get_level(element)
	return base + int(mastery_bonus * 0.5)

func do_prestige() -> int:
	var _game_manager = get_node("/root/GameManager")
	var _mastery_manager = get_node("/root/MasteryManager")
	var _save_system = get_node("/root/SaveSystem")

	var aether_gained = calculate_aether_gain()
	_game_manager.pure_aether += aether_gained
	_game_manager.prestige_count += 1

	# Sıfırlanacaklar
	_reset_hardware()
	_reset_cards()

	# Korunacaklar: Mastery XP, Kaynaklar (yarısı), Saf Aether

	# Çift element başlangıcı aktifse ilk iki elementi 5. seviyeye al
	if _has_upgrade("dual_element_start"):
		var elements = [
			AEnums.ElementType.FIRE,
			AEnums.ElementType.WATER,
		]
		for el in elements:
			_mastery_manager.mastery_xp[el] = max(
				_mastery_manager.mastery_xp.get(el, 0),
				5 * _mastery_manager.XP_PER_LEVEL)

	# Offline çarpan güncelle
	if _has_upgrade("offline_x5"):
		_game_manager.offline_multiplier = 5.0

	if _save_system:
		_save_system.save_all()
	return aether_gained

func _reset_hardware() -> void:
	var _game_manager = get_node("/root/GameManager")
	# Ekstra slot yükseltmesi kadar bonus slot koru
	var extra_slots = purchased_upgrades.get("extra_slot", 0)
	_game_manager.hardware_levels = {
		"cpu_speed":     1,
		"ram_capacity":  1 + extra_slots,
		"battery":       1,
		"mana_capacity": 1,
	}

func _reset_cards() -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	_player_inv.owned_cards.clear()
	_player_inv.pipeline_config.clear()
	# Başlangıç kartlarını laboratuvar yeniden ekleyecek

func can_buy_upgrade(upgrade_id: String) -> bool:
	var _game_manager = get_node("/root/GameManager")
	if not AETHER_UPGRADES.has(upgrade_id):
		return false
	var upgrade = AETHER_UPGRADES[upgrade_id]
	var bought = purchased_upgrades.get(upgrade_id, 0)
	if bought >= upgrade["max_purchases"]:
		return false
	return _game_manager.pure_aether >= upgrade["cost"]

func buy_upgrade(upgrade_id: String) -> bool:
	var _game_manager = get_node("/root/GameManager")
	var _save_system = get_node("/root/SaveSystem")
	if not can_buy_upgrade(upgrade_id):
		return false
	var cost = AETHER_UPGRADES[upgrade_id]["cost"]
	_game_manager.pure_aether -= cost
	purchased_upgrades[upgrade_id] = \
		purchased_upgrades.get(upgrade_id, 0) + 1
	if _save_system:
		_save_system.save_all()
	return true

func _has_upgrade(upgrade_id: String) -> bool:
	return purchased_upgrades.get(upgrade_id, 0) > 0

func get_save_data() -> Dictionary:
	return { "purchased": purchased_upgrades }

func load_save_data(data: Dictionary) -> void:
	purchased_upgrades = data.get("purchased", {})
