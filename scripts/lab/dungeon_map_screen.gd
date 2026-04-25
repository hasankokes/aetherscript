extends Control

@onready var floor_label: Label          = %FloorLabel
@onready var path_container: VBoxContainer = %PathContainer
@onready var hp_bar: ProgressBar         = %HPBar2D
@onready var hp_label: Label             = %HPLabel2D

const DUNGEON_MAP_NODE = preload("res://scenes/ui/dungeon_map_node.tscn")

var current_floor: int = 1
var total_floors: int  = 10

func _ready() -> void:
	%BackButton.pressed.connect(_on_back_button_pressed)
	
	# Eğer oyun yeni başladıysa HP'yi doldur
	var _combat_manager = get_node("/root/CombatManager")
	if _combat_manager.golem_stats.current_hp <= 0:
		_combat_manager.golem_stats.current_hp = _combat_manager.golem_stats.max_hp
	
	_update_hp()
	_generate_map()

func _update_hp() -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var hp = _combat_manager.golem_stats.current_hp
	var max_hp = _combat_manager.golem_stats.max_hp
	hp_bar.value = (hp / max_hp) * 100
	hp_label.text = str(int(hp)) + " / " + str(int(max_hp))

func _generate_map() -> void:
	for child in path_container.get_children():
		child.queue_free()

	floor_label.text = "KAT %d / %d" % [
		current_floor, total_floors]

	# Gösterilecek kat sayısı: mevcut + 3 kat ilerisi
	var show_from = current_floor
	var show_to   = mini(current_floor + 3, total_floors)

	for floor_num in range(show_to, show_from - 1, -1):
		# Üstten başla: en uzak kat en üstte
		var row = HBoxContainer.new()
		row.alignment  = BoxContainer.ALIGNMENT_CENTER
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 16)
		path_container.add_child(row)

		# Mevcut katı vurgula
		var is_current = (floor_num == current_floor)

		var options = _generate_floor_options(floor_num)
		for node_data in options:
			var map_node = DUNGEON_MAP_NODE.instantiate() \
				as DungeonMapNode
			row.add_child(map_node)
			map_node.setup(node_data)
			map_node.node_selected.connect(_on_node_selected)
			
			# Mevcut kat parlasın
			if is_current:
				map_node.modulate = Color(1.2, 1.2, 1.2)
			else:
				map_node.modulate = Color(0.7, 0.7, 0.7)

		# Katlar arası ok (mevcut kat değilse)
		if floor_num > show_from:
			var arrow = Label.new()
			arrow.text = "⬆"
			arrow.horizontal_alignment = \
				HORIZONTAL_ALIGNMENT_CENTER
			arrow.add_theme_color_override(
				"font_color", Color(0.4, 0.4, 0.6))
			path_container.add_child(arrow)

func _generate_floor_options(floor_num: int) -> Array[DungeonNodeData]:
	var options: Array[DungeonNodeData] = []

	# Patron katı
	if floor_num % 10 == 0:
		var boss_node = DungeonNodeData.new()
		boss_node.node_type    = DungeonNodeData.NodeType.BOSS
		boss_node.floor_number = floor_num
		boss_node.reward_multiplier = 3.0
		options.append(boss_node)
		return options

	# Normal katlar: 2-3 seçenek
	var option_count = randi_range(2, 3)
	var possible_types = [
		DungeonNodeData.NodeType.COMBAT,
		DungeonNodeData.NodeType.COMBAT,   # Ağırlık: savaş daha sık
		DungeonNodeData.NodeType.ELITE,
		DungeonNodeData.NodeType.SHOP,
		DungeonNodeData.NodeType.MYSTERY,
		DungeonNodeData.NodeType.REST,
	]

	# Her 5 katta Elite garantili
	if floor_num % 5 == 0:
		var elite = DungeonNodeData.new()
		elite.node_type    = DungeonNodeData.NodeType.ELITE
		elite.floor_number = floor_num
		elite.reward_multiplier = 2.0
		options.append(elite)
		option_count -= 1

	var used_types: Array = []
	for _i in range(option_count):
		var type = possible_types[randi() % possible_types.size()]
		# Aynı tipten 2 tane olmasın
		var attempts = 0
		while used_types.has(type) and attempts < 5:
			type = possible_types[randi() % possible_types.size()]
			attempts += 1
		used_types.append(type)

		var node_data = DungeonNodeData.new()
		node_data.node_type    = type
		node_data.floor_number = floor_num
		node_data.reward_multiplier = \
			2.0 if type == DungeonNodeData.NodeType.ELITE else 1.0
		options.append(node_data)

	return options

func _on_node_selected(node_data: DungeonNodeData) -> void:
	match node_data.node_type:
		DungeonNodeData.NodeType.COMBAT, \
		DungeonNodeData.NodeType.ELITE,  \
		DungeonNodeData.NodeType.BOSS:
			_start_combat(node_data)
		DungeonNodeData.NodeType.REST:
			_handle_rest(node_data)
		DungeonNodeData.NodeType.MYSTERY:
			_handle_mystery(node_data)
		DungeonNodeData.NodeType.SHOP:
			print("Magaza henuz yapim asamasinda.")

func _start_combat(node_data: DungeonNodeData) -> void:
	var _game_manager = get_node("/root/GameManager")
	_game_manager.current_node = node_data
	get_tree().change_scene_to_file("res://scenes/combat/combat_test.tscn")

func _handle_rest(_node_data: DungeonNodeData) -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var heal_amount = _combat_manager.golem_stats.max_hp * 0.3
	_combat_manager.golem_heal(heal_amount)
	var _event_bus = get_node("/root/EventBus")
	_event_bus.golem_hp_changed.emit(
		_combat_manager.golem_stats.current_hp,
		_combat_manager.golem_stats.max_hp)
	current_floor += 1
	_generate_map()

func _handle_mystery(_node_data: DungeonNodeData) -> void:
	var _combat_manager = get_node("/root/CombatManager")
	var _player_inv = get_node("/root/PlayerInventory")
	var roll = randi() % 3
	match roll:
		0:  # İyi olay
			_player_inv.add_resource("crystal", randi_range(3, 8))
			print("Gizem: Kristal buldun!")
		1:  # Kötü olay
			_combat_manager.golem_take_damage(
				_combat_manager.golem_stats.max_hp * 0.1)
			print("Gizem: Tuzak! Hasar aldin.")
		2:  # Yeni kart
			var bonus_card = CardData.new()
			bonus_card.card_name  = "Gizemli Guc"
			bonus_card.card_type  = AEnums.CardType.MODIFIER
			bonus_card.element    = AEnums.ElementType.NEUTRAL
			bonus_card.base_value = 1.5
			_player_inv.add_card(bonus_card)
			print("Gizem: Yeni kart kazandin!")
	current_floor += 1
	_generate_map()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/lab/laboratory_screen.tscn")
