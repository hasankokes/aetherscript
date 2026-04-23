class_name CombatStats
extends Resource

@export var max_hp: float = 100.0
@export var current_hp: float = 100.0
@export var defense: float = 0.0
@export var mana: float = 50.0
@export var max_mana: float = 50.0

# Elementel direnç/zayıflık çarpanları
@export var element_multipliers: Dictionary = {
	AetherEnums.ElementType.FIRE: 1.0,
	AetherEnums.ElementType.WATER: 1.0,
	AetherEnums.ElementType.EARTH: 1.0,
	AetherEnums.ElementType.AIR: 1.0,
	AetherEnums.ElementType.NEUTRAL: 1.0,
}

func take_damage(raw_damage: float, element: AetherEnums.ElementType) -> float:
	var multiplier: float = element_multipliers.get(element, 1.0)
	var mitigated: float = max(0.0, raw_damage * multiplier - defense)
	current_hp = max(0.0, current_hp - mitigated)
	return mitigated  # Gerçek hasar miktarını döndür

func heal(amount: float) -> void:
	current_hp = min(max_hp, current_hp + amount)

func is_dead() -> bool:
	return current_hp <= 0.0

func get_hp_percent() -> float:
	return current_hp / max_hp
