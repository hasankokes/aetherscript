extends PanelContainer

@onready var title_label: Label  = $VBoxContainer/TitleLabel
@onready var desc_label: Label   = $VBoxContainer/DescLabel
@onready var reward_label: Label = $VBoxContainer/RewardLabel
@onready var timer_label: Label  = $VBoxContainer/TimerLabel
@onready var start_button: Button = $VBoxContainer/StartButton

var countdown_timer: Timer

func _ready() -> void:
	var _daily_manager = get_node("/root/DailyChallengeManager")
	var challenge = _daily_manager.get_today_challenge()

	title_label.text = challenge.get("title", "?")
	desc_label.text  = challenge.get("description", "")

	# Ödül metni
	var reward_text = "🎁 Ödül: "
	for resource_id in challenge.get("reward", {}):
		var amount = challenge["reward"][resource_id]
		reward_text += "%d %s  " % [amount,
			resource_id.replace("_", " ").capitalize()]
	reward_label.text = reward_text.strip_edges()

	# Tamamlandıysa butonu kapat
	if _daily_manager.challenge_completed_today:
		start_button.text     = "✅ Tamamlandı!"
		start_button.disabled = true

	# Geri sayım
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.autostart = true
	countdown_timer.timeout.connect(_update_countdown)
	add_child(countdown_timer)
	_update_countdown()

func _update_countdown() -> void:
	var now  = Time.get_unix_time_from_system()
	var next = _get_next_midnight_unix()
	var diff = int(next - now)
	var h = floor(diff / 3600.0)
	var m = floor((diff % 3600) / 60.0)
	var s = diff % 60
	timer_label.text = "Yenilenmesine: %02d:%02d:%02d" % [h, m, s]

func _get_next_midnight_unix() -> int:
	var now_dict = Time.get_datetime_dict_from_system()
	now_dict["hour"]   = 0
	now_dict["minute"] = 0
	now_dict["second"] = 0
	var midnight = Time.get_unix_time_from_datetime_dict(now_dict)
	return int(midnight) + 86400

func _on_start_button_pressed() -> void:
	var _game_manager = get_node("/root/GameManager")
	_game_manager.daily_challenge_active = true
	get_tree().change_scene_to_file(
		"res://scenes/lab/dungeon_map_screen.tscn")
