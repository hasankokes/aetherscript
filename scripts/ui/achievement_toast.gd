extends PanelContainer

@onready var emoji_label:  Label = $HBoxContainer/EmojiLabel
@onready var name_label:   Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var desc_label:   Label = $HBoxContainer/VBoxContainer/DescLabel
@onready var aether_label: Label = $HBoxContainer/VBoxContainer/TitleRow/AetherLabel

func show_achievement(achievement: AchievementData) -> void:
	emoji_label.text  = achievement.emoji
	name_label.text   = achievement.display_name
	desc_label.text   = achievement.description
	if achievement.reward_aether > 0:
		aether_label.text = "+%d ✨" % achievement.reward_aether
	else:
		aether_label.text = ""

	# Sesi çal
	var proc_audio = get_node("/root/ProceduralAudio")
	if proc_audio:
		proc_audio.play_sfx_level_up()

	# Animasyon: sağdan kayarak gir
	var screen_w = get_viewport().get_visible_rect().size.x
	position.x = screen_w + 10
	position.y = 20

	var tween = create_tween()
	tween.tween_property(
		self, "position:x",
		screen_w - size.x - 10, 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.5)
	tween.tween_property(
		self, "position:x",
		screen_w + 10, 0.3)\
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(queue_free)
