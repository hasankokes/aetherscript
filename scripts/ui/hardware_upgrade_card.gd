class_name HardwareUpgradeCard
extends PanelContainer

signal upgrade_purchased(upgrade_data: UpgradeData)

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var cost_label: Label = $VBoxContainer/CostContainer/CostLabel
@onready var upgrade_btn: Button = $VBoxContainer/UpgradeButton

var upgrade_data: UpgradeData = null

func setup(data: UpgradeData) -> void:
	upgrade_data = data
	upgrade_btn.pressed.connect(_on_upgrade_button_pressed)
	refresh()

func refresh() -> void:
	var _game_manager = get_node("/root/GameManager")
	var _player_inv = get_node("/root/PlayerInventory")
	var current_level = _game_manager.hardware_levels.get(
		upgrade_data.hardware_key, 1)
	name_label.text  = upgrade_data.display_name
	level_label.text = "Seviye %d / %d" % [current_level, upgrade_data.max_level]
	desc_label.text  = upgrade_data.get_effect_description(current_level)

	if current_level >= upgrade_data.max_level:
		upgrade_btn.text     = "MAX"
		upgrade_btn.disabled = true
		cost_label.text      = ""
		return

	var cost = upgrade_data.get_cost_at_level(current_level)
	var cost_text = ""
	var can_afford = true
	for resource_id in cost:
		var amount = cost[resource_id]
		var has_enough = _player_inv.has_resource(resource_id, amount)
		if not has_enough:
			can_afford = false
		cost_text += "%d %s  " % [amount, resource_id.replace("_", " ").capitalize()]

	cost_label.text      = cost_text.strip_edges()
	upgrade_btn.disabled = not can_afford

func _on_upgrade_button_pressed() -> void:
	var _game_manager = get_node("/root/GameManager")
	var _player_inv = get_node("/root/PlayerInventory")
	var current_level = _game_manager.hardware_levels.get(
		upgrade_data.hardware_key, 1)
	var cost = upgrade_data.get_cost_at_level(current_level)

	for resource_id in cost:
		if not _player_inv.spend_resource(resource_id, cost[resource_id]):
			return

	_game_manager.hardware_levels[upgrade_data.hardware_key] = current_level + 1
	upgrade_purchased.emit(upgrade_data)
	refresh()
