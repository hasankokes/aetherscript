class_name AetherCard
extends Resource

@export var card_name: String = ""
@export var card_type: AEnums.CardType = AEnums.CardType.ACTION
@export var element: AEnums.ElementType = AEnums.ElementType.NEUTRAL
@export var tier: AEnums.CardTier = AEnums.CardTier.TIER_1
@export var base_value: float = 10.0
@export var cooldown: float = 1.0
@export var mana_cost: int = 0
@export var description: String = ""
@export var icon: Texture2D
@export var synergy_tags: Array[String] = []

# Compile sistemi
@export var compile_progress: float = 0.0
@export var compile_time: float = 30.0
@export var is_compiling: bool = false
@export var compile_start_time: int = 0

# Mutasyon
@export var mutation_id: String = ""
@export var mutation_description: String = ""

func get_tier_multiplier() -> float:
	match tier:
		AEnums.CardTier.TIER_1: return 1.00
		AEnums.CardTier.TIER_2: return 1.40
		AEnums.CardTier.TIER_3: return 1.80
	return 1.0

func get_effective_value() -> float:
	return base_value * get_tier_multiplier()

func get_compile_cost() -> Dictionary:
	match tier:
		AEnums.CardTier.TIER_1:
			return {"iron_ore": 20, "crystal": 10}
		AEnums.CardTier.TIER_2:
			return {"crystal": 25, "aether_shard": 3, "rare_metal": 1}
	return {}

func get_compile_time() -> float:
	match tier:
		AEnums.CardTier.TIER_1: return 30.0
		AEnums.CardTier.TIER_2: return 90.0
	return 0.0

func can_compile() -> bool:
	return tier != AEnums.CardTier.TIER_3 and not is_compiling

func get_tier_label() -> String:
	match tier:
		AEnums.CardTier.TIER_1: return "☆ Tier 1"
		AEnums.CardTier.TIER_2: return "★ Tier 2"
		AEnums.CardTier.TIER_3: return "★★ Tier 3"
	return "?"

func get_tier_color() -> Color:
	match tier:
		AEnums.CardTier.TIER_1: return Color(0.6, 0.6, 0.6)
		AEnums.CardTier.TIER_2: return Color(0.86, 0.65, 0.06)
		AEnums.CardTier.TIER_3: return Color(0.48, 0.18, 0.75)
	return Color.WHITE
