class_name CardData
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
