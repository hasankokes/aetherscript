extends Control

@onready var floor_label: Label          = $FloorLabel
@onready var path_container: VBoxContainer = $PathContainer

const DUNGEON_MAP_NODE = preload("res://scenes/ui/dungeon_map_node.tscn")

var current_floor: int = 1
var total_floors: int  = 10

func _ready() -> void:
    $BackButton.pressed.connect(_on_back_button_pressed)
    _generate_map()

func _generate_map() -> void:
    for child in path_container.get_children():
        child.queue_free()

    floor_label.text = "Kat %d / %d" % [current_floor, total_floors]

    # Her katta 2-3 seçenek sun
    for floor_num in range(current_floor, mini(current_floor + 4, total_floors + 1)):
        var row = HBoxContainer.new()
        row.alignment = BoxContainer.ALIGNMENT_CENTER
        path_container.add_child(row)

        var options = _generate_floor_options(floor_num)
        for node_data in options:
            var map_node = DUNGEON_MAP_NODE.instantiate() as DungeonMapNode
            row.add_child(map_node)
            map_node.setup(node_data)
            map_node.node_selected.connect(_on_node_selected)

        # Patron katı tek seçenek
        if floor_num % 10 == 0:
            break

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
    _combat_manager.golem_stats.heal(heal_amount)
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
            bonus_card.card_type  = AetherEnums.CardType.MODIFIER
            bonus_card.element    = AetherEnums.ElementType.NEUTRAL
            bonus_card.base_value = 1.5
            _player_inv.add_card(bonus_card)
            print("Gizem: Yeni kart kazandin!")
    current_floor += 1
    _generate_map()

func _on_back_button_pressed() -> void:
    get_tree().change_scene_to_file(
        "res://scenes/lab/laboratory_screen.tscn")
