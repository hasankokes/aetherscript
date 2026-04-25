extends Control

@onready var personality_list: VBoxContainer = $Panel/VBoxContainer/PersonalityList

const ALL_PERSONALITIES = [
	"classic", "aether_forge",
	"stone_sentinel", "ember_wraith", "void_runner"
]

func _ready() -> void:
	_build_list()
	$Panel/VBoxContainer/CloseButton.pressed.connect(_on_close_button_pressed)

func _build_list() -> void:
	for child in personality_list.get_children():
		child.queue_free()

	for pid in ALL_PERSONALITIES:
		var path = "res://data/personalities/%s.tres" % pid
		if not ResourceLoader.exists(path):
			continue
		var data = ResourceLoader.load(path) as GolemPersonalityData

		var card = _make_personality_card(data, pid)
		personality_list.add_child(card)

func _make_personality_card(data: GolemPersonalityData, pid: String) -> PanelContainer:
	var is_unlocked = get_node("/root/GolemManager").unlocked_personalities.has(pid)
	var is_active = false
	var active_p = get_node("/root/GolemManager").active_personality
	if active_p:
		is_active = active_p.personality_id == pid

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 80)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.14, 0.22) if is_unlocked else Color(0.07, 0.07, 0.10)
	style.border_color = Color(0.48, 0.18, 0.75) if is_active else Color(0.25, 0.25, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	# Emoji
	var emoji_lbl = Label.new()
	emoji_lbl.text = data.emoji if is_unlocked else "🔒"
	emoji_lbl.add_theme_font_size_override("font_size", 36)
	emoji_lbl.custom_minimum_size.x = 50
	emoji_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(emoji_lbl)

	# Bilgi
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = data.display_name if is_unlocked else "???"
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(0.93, 0.90, 1.0))
	vbox.add_child(name_lbl)

	var desc_lbl = Label.new()
	if is_unlocked:
		desc_lbl.text = data.description
	else:
		desc_lbl.text = data.unlock_condition.replace("_", " ").capitalize()
	
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_lbl)

	if is_unlocked and data.disadvantage_text != "Yok":
		var dis_lbl = Label.new()
		dis_lbl.text = "⚠ " + data.disadvantage_text
		dis_lbl.add_theme_font_size_override("font_size", 10)
		dis_lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.2))
		vbox.add_child(dis_lbl)

	# Seç butonu
	if is_unlocked:
		var btn = Button.new()
		btn.text = "✓ Aktif" if is_active else "Seç"
		btn.disabled = is_active
		btn.custom_minimum_size = Vector2(70, 36)
		btn.pressed.connect(func():
			get_node("/root/GolemManager").switch_personality(pid)
			_build_list()
		)
		hbox.add_child(btn)

	return panel

func _on_close_button_pressed() -> void:
	queue_free()
