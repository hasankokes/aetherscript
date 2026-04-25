class_name CardCompileSlot
extends PanelContainer

@onready var element_label:  Label        = $VBoxContainer/TopRow/ElementLabel
@onready var name_label:     Label        = $VBoxContainer/TopRow/CardNameLabel
@onready var tier_label:     Label        = $VBoxContainer/TopRow/TierLabel
@onready var value_label:    Label        = $VBoxContainer/ValueLabel
@onready var mutation_label: Label        = $VBoxContainer/MutationLabel
@onready var compile_bar:    ProgressBar  = $VBoxContainer/CompileBar
@onready var cost_label:     Label        = $VBoxContainer/CostLabel
@onready var compile_btn:    Button       = $VBoxContainer/CompileButton
@onready var status_label:   Label        = $VBoxContainer/StatusLabel

const ELEMENT_EMOJI = {
	AEnums.ElementType.FIRE:    "🔥",
	AEnums.ElementType.WATER:   "💧",
	AEnums.ElementType.EARTH:   "🌍",
	AEnums.ElementType.AIR:     "💨",
	AEnums.ElementType.NEUTRAL: "⚪",
}

var card: AetherCard = null

func _ready() -> void:
	get_node("/root/CompileManager").compile_completed.connect(
		_on_any_compile_completed)
	get_node("/root/CompileManager").compile_progress_updated.connect(
		_on_progress_updated)
	compile_btn.pressed.connect(_on_compile_button_pressed)

func setup(card_data: AetherCard) -> void:
	card = card_data
	_refresh()

func _refresh() -> void:
	if not card: return
	
	element_label.text = ELEMENT_EMOJI.get(card.element, "?")
	name_label.text    = card.card_name
	tier_label.text    = card.get_tier_label()
	tier_label.add_theme_color_override(
		"font_color", card.get_tier_color())

	# Etki değeri
	var current_val = card.get_effective_value()
	if card.tier != AEnums.CardTier.TIER_3:
		var next_mult = 1.4 if card.tier == AEnums.CardTier.TIER_1 else 1.8
		var next_val = card.base_value * next_mult
		value_label.text = "Etki: %.0f -> %.0f (+%d%%)" % [
			current_val, next_val,
			int((next_mult - 1.0) * 100)]
	else:
		value_label.text = "Etki: %.0f (MAX)" % current_val

	# Mutasyon
	if card.mutation_id != "":
		mutation_label.text    = "✨ " + card.mutation_description
		mutation_label.visible = true
	else:
		mutation_label.visible = false

	# Compile durumu
	if card.is_compiling:
		_set_compiling_state()
	elif card.tier == AEnums.CardTier.TIER_3:
		_set_max_state()
	else:
		_set_idle_state()

func _set_idle_state() -> void:
	compile_bar.visible  = false
	status_label.text    = ""
	compile_btn.disabled = false
	compile_btn.text     = "⚗️ Compile Et"

	var cost = card.get_compile_cost()
	var cost_parts = []
	var can_afford = true
	for resource_id in cost:
		var amount = cost[resource_id]
		if not get_node("/root/PlayerInventory").has_resource(resource_id, amount):
			can_afford = false
		cost_parts.append("%d %s" % [amount,
			resource_id.replace("_", " ").capitalize()])
	cost_label.text      = " | ".join(cost_parts)
	compile_btn.disabled = not can_afford

	var compile_secs = card.get_compile_time()
	compile_btn.text = "⚗️ Compile (%ds)" % int(compile_secs)

func _set_compiling_state() -> void:
	compile_bar.visible  = true
	compile_bar.value    = card.compile_progress * 100.0
	compile_btn.disabled = true
	compile_btn.text     = "⏳ Derleniyor..."
	cost_label.text      = ""
	var remaining = card.compile_time * (1.0 - card.compile_progress)
	status_label.text = "%.0f sn kaldı" % remaining

func _set_max_state() -> void:
	compile_bar.visible  = false
	compile_btn.disabled = true
	compile_btn.text     = "✓ MAX TIER"
	cost_label.text      = ""
	status_label.text    = "Tier 3 — Tam Güç"
	status_label.add_theme_color_override(
		"font_color", Color(0.48, 0.18, 0.75))

func _on_compile_button_pressed() -> void:
	if get_node("/root/CompileManager").start_compile(card):
		_set_compiling_state()

func _on_any_compile_completed(completed_card: AetherCard) -> void:
	if completed_card == card:
		_refresh()
		status_label.text = "✓ Tamamlandı!"
		status_label.add_theme_color_override(
			"font_color", Color(0.2, 0.9, 0.3))

func _on_progress_updated(
		updated_card: AetherCard,
		progress: float) -> void:
	if updated_card == card and card.is_compiling:
		compile_bar.value = progress * 100.0
		var remaining = card.compile_time * (1.0 - progress)
		status_label.text = "%.0f sn kaldı" % remaining
