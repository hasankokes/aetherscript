extends Control

signal prestige_confirmed()
signal prestige_cancelled()

@onready var aether_gain_label: Label    = $Panel/AetherGainLabel
@onready var aether_balance_label: Label = $Panel/AetherBalanceLabel
@onready var upgrade_list: VBoxContainer = $Panel/UpgradeList

func _ready() -> void:
	var _prestige_manager = get_node("/root/PrestigeManager")
	var _game_manager = get_node("/root/GameManager")

	var gain = _prestige_manager.calculate_aether_gain()
	aether_gain_label.text = "+%d Saf Aether kazanacaksın" % gain
	aether_balance_label.text = "Mevcut: %d Saf Aether" % \
		_game_manager.pure_aether
	_build_upgrade_list()

func _build_upgrade_list() -> void:
	var _prestige_manager = get_node("/root/PrestigeManager")
	for child in upgrade_list.get_children():
		child.queue_free()

	for upgrade_id in _prestige_manager.AETHER_UPGRADES:
		var upgrade = _prestige_manager.AETHER_UPGRADES[upgrade_id]
		var bought   = _prestige_manager.purchased_upgrades.get(upgrade_id, 0)
		var max_buy  = upgrade["max_purchases"]

		var row = HBoxContainer.new()
		upgrade_list.add_child(row)

		var info_lbl = Label.new()
		info_lbl.text = "%s (%d✨) [%d/%d]" % [
			upgrade["display"], upgrade["cost"], bought, max_buy]
		info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_lbl)

		var buy_btn = Button.new()
		buy_btn.text = "Al"
		buy_btn.disabled = not _prestige_manager.can_buy_upgrade(upgrade_id)
		buy_btn.pressed.connect(
			func():
				if _prestige_manager.buy_upgrade(upgrade_id):
					_refresh()
		)
		row.add_child(buy_btn)

func _refresh() -> void:
	var _game_manager = get_node("/root/GameManager")
	aether_balance_label.text = "Mevcut: %d Saf Aether" % \
		_game_manager.pure_aether
	_build_upgrade_list()

func _on_confirm_button_pressed() -> void:
	var _proc_audio = get_node("/root/ProceduralAudio")
	if _proc_audio:
		_proc_audio.play_sfx_prestige()
		await get_tree().create_timer(0.5).timeout

	var _prestige_manager = get_node("/root/PrestigeManager")
	var _gained = _prestige_manager.do_prestige()
	prestige_confirmed.emit()
	queue_free()

func _on_cancel_button_pressed() -> void:
	prestige_cancelled.emit()
	queue_free()
