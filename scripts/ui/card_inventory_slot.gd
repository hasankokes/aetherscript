class_name CardInventorySlot
extends PanelContainer

signal card_selected(card: CardData)

@onready var card_name_label: Label = $VBoxContainer/TopRow/CardNameLabel
@onready var element_label: Label   = $VBoxContainer/TopRow/ElementLabel
@onready var type_label: Label      = $VBoxContainer/TypeLabel
@onready var tier_label: Label      = $VBoxContainer/TierLabel
@onready var select_button: Button = $VBoxContainer/SelectButton

var card_data: CardData = null

const ELEMENT_EMOJI = {
	AetherEnums.ElementType.FIRE:    "🔥",
	AetherEnums.ElementType.WATER:   "💧",
	AetherEnums.ElementType.EARTH:   "🌿",
	AetherEnums.ElementType.AIR:     "💨",
	AetherEnums.ElementType.NEUTRAL: "⚪",
}

const TIER_TEXT = {
	AetherEnums.CardTier.TIER_1: "* Tier 1",
	AetherEnums.CardTier.TIER_2: "** Tier 2",
	AetherEnums.CardTier.TIER_3: "*** Tier 3",
}

func setup(card: CardData) -> void:
	card_data = card
	card_name_label.text = card.card_name
	element_label.text   = ELEMENT_EMOJI.get(card.element, "?")
	tier_label.text      = TIER_TEXT.get(card.tier, "?")
	
	match card.card_type:
		AetherEnums.CardType.ACTION:
			type_label.text = "ACTION"
			type_label.modulate = Color(1.0, 0.4, 0.4)
		AetherEnums.CardType.MODIFIER:
			type_label.text = "MODIFIER"
			type_label.modulate = Color(0.4, 1.0, 0.4)
		AetherEnums.CardType.LOGIC:
			type_label.text = "LOGIC"
			type_label.modulate = Color(0.4, 0.4, 1.0)
	
	if not select_button.pressed.is_connected(_on_select_button_pressed):
		select_button.pressed.connect(_on_select_button_pressed)

func _on_select_button_pressed() -> void:
	card_selected.emit(card_data)
