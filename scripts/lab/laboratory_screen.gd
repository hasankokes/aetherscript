extends Control

@onready var upgrade_list: VBoxContainer  = %UpgradeList
@onready var card_grid: GridContainer     = %CardGrid
@onready var resource_list: VBoxContainer = %ResourceList
@onready var pipeline_bar: PipelineBar    = %PipelineBar
@onready var save_label: Label            = %SaveLabel
@onready var prestige_button: Button      = %PrestigeButton

const HARDWARE_UPGRADE_CARD = preload("res://scenes/ui/hardware_upgrade_card.tscn")
const CARD_INVENTORY_SLOT   = preload("res://scenes/ui/card_inventory_slot.tscn")

var upgrade_definitions: Array[UpgradeData] = []

func _ready() -> void:
	%RunButton.pressed.connect(_on_run_button_pressed)
	_create_upgrade_definitions()
	_build_hardware_tab()
	_build_card_tab()
	_build_resource_tab()
	_load_pipeline()
	$TabContainer.current_tab = 1
	save_label.visible = false

	var auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0
	auto_save_timer.autostart = true
	auto_save_timer.timeout.connect(func():
		var _save = get_node("/root/SaveSystem")
		if _save: _save.save_all()
	)
	add_child(auto_save_timer)

	_update_prestige_button()
	var _event_bus = get_node("/root/EventBus")
	_event_bus.run_ended.connect(func(_f, _l): _update_prestige_button())

func _update_prestige_button() -> void:
	var _prestige_manager = get_node("/root/PrestigeManager")
	var _game_manager = get_node("/root/GameManager")
	var required = _prestige_manager.get_prestige_floor_requirement()
	var best     = _game_manager.best_floor
	prestige_button.visible = best >= required
	if prestige_button.visible:
		prestige_button.text = "⚗️ Büyük Sentez (En İyi: %d/%d kat)" % [
			best, required]

func _on_prestige_button_pressed() -> void:
	const PRESTIGE_SCREEN = preload(
		"res://scenes/ui/prestige_screen.tscn")
	var screen = PRESTIGE_SCREEN.instantiate()
	add_child(screen)
	screen.prestige_confirmed.connect(func():
		_build_card_tab()
		_build_hardware_tab()
		_build_resource_tab()
		_update_prestige_button())
	screen.prestige_cancelled.connect(func(): pass)

func _create_upgrade_definitions() -> void:
	var upgrades_raw = [
		["cpu_speed",    "CPU Hizi",       "Imlec daha hizli akar.",       {"iron_ore": 10},            20],
		["ram_capacity", "RAM Kapasitesi", "Pipeline slot sayisi artar.",   {"crystal": 15, "iron_ore": 10}, 3],
		["battery",      ["Batarya (HP)"],   "Golem maksimum cani artar.",    {"iron_ore": 8, "organic_core": 5}, 50],
		["mana_capacity","Mana Kapasitesi","Mana havuzu buyur.",            {"crystal": 12},             15],
	]
	# Fix for battery key being an array in raw data
	for raw in upgrades_raw:
		var ud = UpgradeData.new()
		ud.hardware_key  = raw[0]
		ud.display_name  = raw[1] if typeof(raw[1]) == TYPE_STRING else raw[1][0]
		ud.description   = raw[2]
		ud.base_cost     = raw[3]
		ud.max_level     = raw[4]
		upgrade_definitions.append(ud)

func _build_hardware_tab() -> void:
	for child in upgrade_list.get_children():
		child.queue_free()
	for ud in upgrade_definitions:
		var card = HARDWARE_UPGRADE_CARD.instantiate() as HardwareUpgradeCard
		upgrade_list.add_child(card)
		card.setup(ud)
		card.upgrade_purchased.connect(_on_upgrade_purchased)

func _build_card_tab() -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	for child in card_grid.get_children():
		child.queue_free()

	# Envanter bossa baslangic kartlarini ekle
	if _player_inv.owned_cards.is_empty():
		_add_starter_cards()

	for card_data in _player_inv.owned_cards:
		var slot = CARD_INVENTORY_SLOT.instantiate() as CardInventorySlot
		card_grid.add_child(slot)
		slot.setup(card_data)
		slot.card_selected.connect(_on_card_selected_for_pipeline)

func _add_starter_cards() -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	var starters = [
		["Fireball",      AetherEnums.CardType.ACTION,   AetherEnums.ElementType.FIRE,    35.0],
		["Aqua Pulse",    AetherEnums.CardType.ACTION,   AetherEnums.ElementType.WATER,   25.0],
		["Stone Wall",    AetherEnums.CardType.ACTION,   AetherEnums.ElementType.EARTH,   0.0],
		["Wind Slash",    AetherEnums.CardType.ACTION,   AetherEnums.ElementType.AIR,     20.0],
		["Hasar x2",      AetherEnums.CardType.MODIFIER, AetherEnums.ElementType.NEUTRAL, 2.0],
		["HP<30: Heal",   AetherEnums.CardType.LOGIC,    AetherEnums.ElementType.NEUTRAL, 30.0],
	]
	for s in starters:
		var card = CardData.new()
		card.card_name  = s[0]
		card.card_type  = s[1]
		card.element    = s[2]
		card.base_value = s[3]
		_player_inv.add_card(card)

func _build_resource_tab() -> void:
	var _player_inv = get_node("/root/PlayerInventory")
	for child in resource_list.get_children():
		child.queue_free()
	var emoji = {
		"iron_ore": "Iron", "crystal": "Crystal",
		"aether_shard": "Aether", "rare_metal": "Rare Metal", "organic_core": "Organic"
	}
	for resource_id in _player_inv.resources:
		var lbl = Label.new()
		lbl.text = "%s: %d" % [
			emoji.get(resource_id, resource_id),
			_player_inv.resources[resource_id]
		]
		resource_list.add_child(lbl)

func _load_pipeline() -> void:
	# Önce tüm slotları temizle
	var slot_count = GameManager.get_pipeline_slot_count()
	for i in range(slot_count):
		pipeline_bar.clear_slot(i)
	
	# Sonra kayıtlı konfigürasyonu yükle
	for slot_index in PlayerInventory.pipeline_config:
		var card = PlayerInventory.pipeline_config[slot_index]
		pipeline_bar.set_card_in_slot(slot_index, card)

func _on_card_selected_for_pipeline(card: CardData) -> void:
	var slot_count = GameManager.get_pipeline_slot_count()
	
	# Bu kart zaten pipeline'da mı? Varsa çıkar (toggle)
	for i in range(slot_count):
		if PlayerInventory.pipeline_config.has(i):
			if PlayerInventory.pipeline_config[i].card_name \
			   == card.card_name \
			   and PlayerInventory.pipeline_config[i].element \
			   == card.element:
				PlayerInventory.remove_card_from_pipeline(i)
				pipeline_bar.clear_slot(i)
				return
	
	# İlk boş slotu bul
	for i in range(slot_count):
		if not PlayerInventory.pipeline_config.has(i):
			PlayerInventory.set_card_in_pipeline(i, card)
			pipeline_bar.set_card_in_slot(i, card)
			return
	
	# Tüm slotlar dolu
	print("Pipeline dolu! Önce bir kartı çıkar.")

func _on_upgrade_purchased(_upgrade_data: UpgradeData) -> void:
	_build_hardware_tab()
	_build_resource_tab()
	if _upgrade_data.hardware_key == "ram_capacity":
		pipeline_bar.build_pipeline(GameManager.get_pipeline_slot_count())

func _on_run_button_pressed() -> void:
	PlayerInventory.save()
	get_tree().change_scene_to_file(
		"res://scenes/lab/dungeon_map_screen.tscn")
