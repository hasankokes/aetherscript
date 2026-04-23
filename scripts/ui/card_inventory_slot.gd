class_name CardInventorySlot
extends PanelContainer

signal card_selected(card: CardData)

@onready var card_name_label: Label = $CardNameLabel
@onready var element_label: Label   = $ElementLabel
@onready var tier_label: Label      = $TierLabel

var card_data: CardData = null

const ELEMENT_TEXT = {
	AetherEnums.ElementType.FIRE:    "FIRE Ates",
	AetherEnums.ElementType.WATER:   "WATER Su",
	AetherEnums.ElementType.EARTH:   "EARTH Toprak",
	AetherEnums.ElementType.AIR:     "AIR Hava",
	AetherEnums.ElementType.NEUTRAL: "NEUTRAL Notr",
}

const TIER_TEXT = {
	AetherEnums.CardTier.TIER_1: "* Tier 1",
	AetherEnums.CardTier.TIER_2: "** Tier 2",
	AetherEnums.CardTier.TIER_3: "*** Tier 3",
}

func setup(card: CardData) -> void:
	card_data = card
	card_name_label.text = card.card_name
	element_label.text   = ELEMENT_TEXT.get(card.element, "?")
	tier_label.text      = TIER_TEXT.get(card.tier, "?")
	$SelectButton.pressed.connect(_on_select_button_pressed)

func _on_select_button_pressed() -> void:
	card_selected.emit(card_data)
