extends Control

@onready var pipeline_bar: PipelineBar = %PipelineBar
@onready var enemy: Enemy = %Enemy
@onready var _combat_manager: Node = get_node("/root/CombatManager")

var run_start_time: float = 0.0
var current_floor: int = 0

func _ready() -> void:
	run_start_time = Time.get_ticks_msec() / 1000.0
	var _event_bus = get_node("/root/EventBus")
	%StartButton.pressed.connect(_on_start_pressed)
	%EnemyAttackButton.pressed.connect(_on_enemy_attack_pressed)
	_event_bus.run_ended.connect(_on_run_ended)

	# Test düşmanı oluştur
	var test_enemy_data = EnemyData.new()
	test_enemy_data.enemy_name = "Test Goblin"
	test_enemy_data.base_hp = 200.0
	test_enemy_data.base_defense = 5.0
	var weak_elements: Array[AetherEnums.ElementType] = [AetherEnums.ElementType.FIRE]
	test_enemy_data.weak_to = weak_elements

	enemy.setup(test_enemy_data)
	_combat_manager.register_enemy(enemy)

	# Test kartlarını pipeline'a yükle
	var cards = [
		_make_card("Fireball", AetherEnums.CardType.ACTION,
				   AetherEnums.ElementType.FIRE, 30.0),
		_make_card("Hasar x2", AetherEnums.CardType.MODIFIER,
				   AetherEnums.ElementType.NEUTRAL, 2.0),
		_make_card("Fireball", AetherEnums.CardType.ACTION,
				   AetherEnums.ElementType.FIRE, 30.0),
		_make_card("HP<30: Heal", AetherEnums.CardType.LOGIC,
				   AetherEnums.ElementType.NEUTRAL, 25.0),
		_make_card("Aqua Pulse", AetherEnums.CardType.ACTION,
				   AetherEnums.ElementType.WATER, 20.0),
	]
	for i in range(cards.size()):
		pipeline_bar.set_card_in_slot(i, cards[i])

func _make_card(card_name: String, type: AetherEnums.CardType,
				element: AetherEnums.ElementType, value: float) -> CardData:
	var card = CardData.new()
	card.card_name = card_name
	card.card_type = type
	card.element = element
	card.base_value = value
	return card

func _on_start_pressed() -> void:
	pipeline_bar.start_pipeline()

func _on_enemy_attack_pressed() -> void:
	_combat_manager.golem_take_damage(15.0)

func _on_run_ended(floor_reached: int, _loot: Dictionary) -> void:
	var _game_manager = get_node("/root/GameManager")
	var _player_inv = get_node("/root/PlayerInventory")
	var _event_bus = get_node("/root/EventBus")
	var _save_system = get_node("/root/SaveSystem")

	var duration = (Time.get_ticks_msec() / 1000.0) - run_start_time
	_game_manager.record_run(current_floor, duration)
	_game_manager.total_kills += 1

	if _game_manager.daily_challenge_active:
		var _daily = get_node("/root/DailyChallengeManager")
		# Basitçe 1 katı bile geçse daily bitmiş sayalım test için
		_daily.complete_challenge()
		_game_manager.daily_challenge_active = false

	# Ganimet hesapla ve ekle
	var reward_mult = 1.0
	_player_inv.add_resource("iron_ore", int(randi_range(5, 15) * reward_mult))
	_player_inv.add_resource("crystal", int(randi_range(1, 5) * reward_mult))
	if randf() < 0.15:
		_player_inv.add_resource("aether_shard", 1)

	# Mastery XP — tur tamamlamak bonus verir
	for element in _game_manager.mastery_levels:
		_event_bus.mastery_xp_gained.emit(element, 5)

	if _save_system:
		_save_system.save_all()

	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/lab/laboratory_screen.tscn")
