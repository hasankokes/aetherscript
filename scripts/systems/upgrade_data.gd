class_name UpgradeData
extends Resource

@export var upgrade_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var hardware_key: String = ""   # GameManager.hardware_levels anahtarı
@export var max_level: int = 10
@export var base_cost: Dictionary = {}  # {"iron_ore": 10, "crystal": 5}
@export var cost_scaling: float = 1.4  # Her seviyede maliyet çarpanı

func get_cost_at_level(level: int) -> Dictionary:
	var scaled: Dictionary = {}
	for resource_id in base_cost:
		scaled[resource_id] = int(base_cost[resource_id] * pow(cost_scaling, level))
	return scaled

func get_effect_description(level: int) -> String:
	match hardware_key:
		"cpu_speed":      return "Imlec Hizi: +%d%%" % (level * 10)
		"ram_capacity":   return "Pipeline Slot: %d" % (8 + (level - 1) * 2)
		"battery":        return "Golem HP: +%d" % (level * 20)
		"mana_capacity":  return "Mana: +%d" % (level * 10)
		_:                return "Seviye %d" % level
