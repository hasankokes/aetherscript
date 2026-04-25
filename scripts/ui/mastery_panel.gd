extends VBoxContainer

const ELEMENT_DATA = [
	[AEnums.ElementType.FIRE,  "FIRE", Color(1.0, 0.3, 0.1)],
	[AEnums.ElementType.WATER, "WATER", Color(0.1, 0.8, 1.0)],
	[AEnums.ElementType.EARTH, "EARTH", Color(0.7, 0.5, 0.1)],
	[AEnums.ElementType.AIR,   "AIR", Color(0.8, 0.95, 1.0)],
]

var rows: Dictionary = {}

func _ready() -> void:
	_build_rows()
	var _event_bus = get_node("/root/EventBus")
	_event_bus.mastery_xp_gained.connect(_on_xp_updated)
	_event_bus.synergy_triggered.connect(_on_synergy_unlocked)

func _build_rows() -> void:
	for data in ELEMENT_DATA:
		var element = data[0]
		var emoji   = data[1]
		var color   = data[2]

		var row = HBoxContainer.new()

		var emoji_lbl = Label.new()
		emoji_lbl.text = emoji
		emoji_lbl.custom_minimum_size.x = 40

		var level_lbl = Label.new()
		level_lbl.custom_minimum_size.x = 80

		var xp_bar = ProgressBar.new()
		xp_bar.custom_minimum_size = Vector2(120, 16)
		xp_bar.max_value = 1.0
		xp_bar.modulate  = color

		var bonus_lbl = Label.new()
		bonus_lbl.custom_minimum_size.x = 90

		row.add_child(emoji_lbl)
		row.add_child(level_lbl)
		row.add_child(xp_bar)
		row.add_child(bonus_lbl)
		$ElementsContainer.add_child(row)

		rows[element] = {
			"level": level_lbl,
			"xp_bar": xp_bar,
			"bonus": bonus_lbl,
		}
		_refresh_row(element)

func _refresh_row(element: AEnums.ElementType) -> void:
	var _mastery_manager = get_node("/root/MasteryManager")
	var level    = _mastery_manager.get_level(element)
	var progress = _mastery_manager.get_xp_progress(element)
	var bonus    = int(level * _mastery_manager.DAMAGE_BONUS_PER_LEVEL * 100)
	var r        = rows[element]
	r["level"].text  = "Sv. %d" % level
	r["xp_bar"].value = progress
	r["bonus"].text  = "+%d%% Hasar" % bonus

func _on_xp_updated(element: AEnums.ElementType, _amount: int) -> void:
	if element != AEnums.ElementType.NEUTRAL:
		_refresh_row(element)

func _on_synergy_unlocked(synergy_id: String) -> void:
	# Kısa bildirim göster
	var notif = Label.new()
	notif.text = "Sinerji Acildi: %s" % synergy_id.replace("_", " + ").to_upper()
	notif.modulate = Color(1.0, 0.9, 0.2)
	add_child(notif)
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(notif.queue_free)
