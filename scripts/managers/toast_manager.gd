extends Node

const TOAST_SCENE = preload("res://scenes/ui/achievement_toast.tscn")

var _toast_queue: Array[AchievementData] = []
var _showing: bool = false

func _ready() -> void:
	var am = get_node("/root/AchievementManager")
	am.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement: AchievementData) -> void:
	_toast_queue.append(achievement)
	if not _showing:
		_show_next()

func _show_next() -> void:
	if _toast_queue.is_empty():
		_showing = false
		return
	_showing = true
	var achievement = _toast_queue.pop_front()
	var toast = TOAST_SCENE.instantiate()
	get_tree().root.add_child(toast)
	toast.show_achievement(achievement)
	await get_tree().create_timer(3.2).timeout
	_show_next()
