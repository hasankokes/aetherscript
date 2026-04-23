class_name PipelineSlot
extends PanelContainer

signal card_dropped(card_data: CardData, slot_index: int)
signal card_removed(slot_index: int)

@onready var card_icon: TextureRect  = $CardIcon
@onready var card_name_label: Label  = $CardNameLabel
@onready var active_glow: ColorRect  = $ActiveGlow
@onready var cooldown_overlay: ColorRect = $CooldownOverlay
@onready var empty_label: Label      = $EmptyLabel
@onready var element_bar: ColorRect  = $ElementBar   # Slot altında ince renkli çizgi
@onready var type_indicator: ColorRect = $TypeIndicator # Sol üst köşe rengi

var slot_index: int = 0
var current_card: CardData = null

func _ready() -> void:
	custom_minimum_size = Vector2(64, 80)
	set_empty()

func set_card(card: CardData) -> void:
	current_card = card
	card_name_label.text = card.card_name
	card_name_label.visible = true
	empty_label.visible = false

	if card.icon:
		card_icon.texture = card.icon
		card_icon.visible = true

	# Element rengi — alt çizgi
	var _aether_theme = get_node("/root/AetherTheme")
	var el_color = _aether_theme.get_element_color(card.element)
	element_bar.color = el_color

	# Kart türü rengi — sol köşe
	var type_color = _aether_theme.get_card_type_color(card.card_type)
	type_indicator.color = type_color

	# Panel border rengini element rengiyle güncelle
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.border_color = el_color
	add_theme_stylebox_override("panel", style)

func set_empty() -> void:
	current_card = null
	card_icon.visible = false
	card_name_label.visible = false
	empty_label.visible = true
	active_glow.visible = false
	active_glow.modulate.a = 0.0
	cooldown_overlay.modulate.a = 0.0
	var _aether_theme = get_node("/root/AetherTheme")
	element_bar.color = _aether_theme.COLOR_NEUTRAL
	type_indicator.color = Color.TRANSPARENT

	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.border_color = _aether_theme.COLOR_PURPLE
	add_theme_stylebox_override("panel", style)

func activate() -> void:
	active_glow.visible = true
	var glow_color = Color.WHITE
	if current_card:
		var _aether_theme = get_node("/root/AetherTheme")
		glow_color = _aether_theme.get_element_glow(current_card.element)
	active_glow.color = glow_color
	active_glow.modulate.a = 0.85

	# Nabız animasyonu
	var tween = create_tween().set_loops(1)
	tween.tween_property(self, "scale", Vector2(1.10, 1.10), 0.07)
	tween.tween_property(self, "scale", Vector2(1.00, 1.00), 0.07)

	# Glow fade out
	var glow_tween = create_tween()
	glow_tween.tween_property(active_glow, "modulate:a", 0.0, 0.35)

func deactivate() -> void:
	active_glow.visible = false
	active_glow.modulate.a = 0.0

func set_cooldown_progress(progress: float) -> void:
	cooldown_overlay.modulate.a = (1.0 - progress) * 0.55
