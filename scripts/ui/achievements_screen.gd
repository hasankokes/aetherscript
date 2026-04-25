extends Control

@onready var progress_label:    Label         = $Panel/VBoxContainer/ProgressLabel
@onready var achievement_list:  VBoxContainer = $Panel/VBoxContainer/ScrollContainer/AchievementList
@onready var stats_grid:        GridContainer = $Panel/VBoxContainer/StatsSection/StatsGrid

func _ready() -> void:
	_build_achievements()
	_build_stats()
	$Panel/VBoxContainer/HeaderRow/CloseButton.pressed.connect(_on_close_button_pressed)

func _build_achievements() -> void:
	var am = get_node("/root/AchievementManager")
	for child in achievement_list.get_children():
		child.queue_free()

	var unlocked_count = 0
	var total_visible  = 0

	for ach in am.ACHIEVEMENTS:
		var is_unlocked = am.unlocked_ids.has(ach["id"])
		var is_hidden   = ach.get("hidden", false)

		if is_hidden and not is_unlocked:
			continue

		total_visible += 1
		if is_unlocked:
			unlocked_count += 1

		var row = _make_achievement_row(ach, is_unlocked)
		achievement_list.add_child(row)

	progress_label.text = "%d / %d tamamlandı" % [unlocked_count, total_visible]

func _make_achievement_row(ach: Dictionary, is_unlocked: bool) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 56)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.18, 0.25) if is_unlocked else Color(0.07, 0.07, 0.10)
	style.border_color = Color(0.86, 0.65, 0.06) if is_unlocked else Color(0.20, 0.20, 0.28)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	# Emoji
	var emoji = Label.new()
	emoji.text = ach["emoji"] if is_unlocked else "🔒"
	emoji.add_theme_font_size_override("font_size", 28)
	emoji.custom_minimum_size.x = 40
	emoji.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	if not is_unlocked:
		emoji.modulate = Color(0.4, 0.4, 0.4)
	hbox.add_child(emoji)

	# Bilgi
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = ach["name"] if is_unlocked else "???"
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", Color(0.93, 0.90, 1.0) if is_unlocked else Color(0.4, 0.4, 0.5))
	vbox.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = ach["desc"] if is_unlocked else "Gizli başarım"
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(desc_lbl)

	# Ödül
	if is_unlocked and ach.get("reward_aether", 0) > 0:
		var reward = Label.new()
		reward.text = "+%d ✨" % ach["reward_aether"]
		reward.add_theme_font_size_override("font_size", 11)
		reward.add_theme_color_override("font_color", Color(0.48, 0.18, 0.75))
		reward.custom_minimum_size.x = 60
		reward.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(reward)

	return panel

func _build_stats() -> void:
	var am = get_node("/root/AchievementManager")
	var gm = get_node("/root/GameManager")
	for child in stats_grid.get_children():
		child.queue_free()

	var stats_display = [
		["⚔️  Toplam Öldürme", str(gm.total_kills)],
		["🏆 En Yüksek Kat",   str(am.stats["best_floor"])],
		["🔄 Toplam Tur",      str(gm.total_runs)],
		["⚗️  Prestige Sayısı", str(gm.prestige_count)],
		["✨ Saf Aether",      str(gm.pure_aether)],
		["🎵 Max Combo",       str(am.stats["max_combo"])],
		["💜 Tier 3 Kart",     str(am.stats["tier3_count"])],
		["⚡ Ultimate Kullanım", str(am.stats["ultimate_count"])],
	]

	for pair in stats_display:
		var key_lbl = Label.new()
		key_lbl.text = pair[0]
		key_lbl.add_theme_font_size_override("font_size", 12)
		key_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.75))
		stats_grid.add_child(key_lbl)

		var val_lbl = Label.new()
		val_lbl.text = pair[1]
		val_lbl.add_theme_font_size_override("font_size", 13)
		val_lbl.add_theme_color_override("font_color", Color(0.93, 0.90, 1.0))
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_grid.add_child(val_lbl)

func _on_close_button_pressed() -> void:
	queue_free()
