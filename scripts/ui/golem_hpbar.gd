extends HBoxContainer

@onready var hp_bar: ProgressBar    = $HPProgressBar
@onready var hp_label: Label        = $HPLabel
@onready var combo_label: Label     = $ComboLabel

func _ready() -> void:
	EventBus.golem_hp_changed.connect(_on_hp_changed)
	EventBus.combo_counter_changed.connect(_on_combo_changed)
	combo_label.visible = false
	
	# Bir frame bekle — tüm Autoload'lar yüklensin
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Mevcut değeri doğrudan oku
	var current = CombatManager.golem_stats.current_hp
	var maximum = CombatManager.golem_stats.max_hp
	
	if maximum > 0:
		_on_hp_changed(current, maximum)
	else:
		# CombatManager henüz hazır değil — setup'ı tetikle
		CombatManager._setup_golem()

func _on_hp_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(maximum)]

	# HP kritikse renk değiştir
	if maximum > 0:
		var ratio = current / maximum
		if ratio < 0.3:
			hp_bar.modulate = Color(1.0, 0.2, 0.2)
		elif ratio < 0.6:
			hp_bar.modulate = Color(1.0, 0.7, 0.1)
		else:
			hp_bar.modulate = Color(0.2, 0.9, 0.3)

func _on_combo_changed(count: int, element: AEnums.ElementType) -> void:
	if count < 2:
		combo_label.visible = false
		return

	var element_emojis = {
		AEnums.ElementType.FIRE:  "FIRE",
		AEnums.ElementType.WATER: "WATER",
		AEnums.ElementType.EARTH: "EARTH",
		AEnums.ElementType.AIR:   "AIR",
	}
	var emoji = element_emojis.get(element, "ELEM")
	combo_label.text = "COMBO x%d %s" % [count, emoji]
	combo_label.visible = true

	# Renge göre renk
	var _aether_theme = get_node("/root/AetherTheme")
	var color = _aether_theme.get_element_color(element)
	combo_label.modulate = color

	# Combo büyüklüğü arttıkça animasyon sertleşir
	var scale_target = 1.2 + (count * 0.05)
	scale_target = minf(scale_target, 1.6)

	if combo_tween:
		combo_tween.kill()
	combo_tween = create_tween()
	combo_tween.tween_property(combo_label, "scale", Vector2(scale_target, scale_target), 0.08)
	combo_tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.12)

	# Combo 5+ ise ekran hafif titreşir
	if count >= 5:
		_screen_shake(count)

var combo_tween: Tween = null

func _screen_shake(intensity: int) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
	var original = camera.offset
	var shake_tween = create_tween()
	for _i in range(4):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity))
		shake_tween.tween_property(camera, "offset", offset, 0.04)
	shake_tween.tween_property(camera, "offset", original, 0.04)
