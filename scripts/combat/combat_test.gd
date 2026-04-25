extends Control

@onready var pipeline_bar: PipelineBar = %PipelineBar
@onready var enemy: Enemy = %Enemy
@onready var _combat_manager: Node = get_node("/root/CombatManager")

var run_start_time: float = 0.0
var current_floor: int = 0

func _ready() -> void:
	# Golem verilerini hazırla
	var cm = get_node("/root/CombatManager")
	if cm.golem_stats.current_hp <= 0:
		cm.golem_stats.current_hp = cm.golem_stats.max_hp
	
	run_start_time = Time.get_ticks_msec() / 1000.0
	var eb = get_node("/root/EventBus")
	%StartButton.pressed.connect(_on_start_pressed)
	eb.run_ended.connect(_on_run_ended)

	# Test düşmanı oluştur
	var test_enemy_data = EnemyData.new()
	test_enemy_data.enemy_name = "Test Goblin"
	test_enemy_data.emoji = "👹"
	test_enemy_data.base_hp = 200.0
	test_enemy_data.base_defense = 5.0
	var weak_elements: Array[AEnums.ElementType] = [AEnums.ElementType.FIRE]
	test_enemy_data.weak_to = weak_elements

	enemy.setup(test_enemy_data)
	cm.register_enemy(enemy)

	# Test kartlarını pipeline'a yükle
	var cards = [
		_make_card("Fireball", AEnums.CardType.ACTION,
				   AEnums.ElementType.FIRE, 30.0),
		_make_card("Hasar x2", AEnums.CardType.MODIFIER,
				   AEnums.ElementType.NEUTRAL, 2.0),
		_make_card("Fireball", AEnums.CardType.ACTION,
				   AEnums.ElementType.FIRE, 30.0),
		_make_card("HP<30: Heal", AEnums.CardType.LOGIC,
				   AEnums.ElementType.NEUTRAL, 25.0),
		_make_card("Aqua Pulse", AEnums.CardType.ACTION,
				   AEnums.ElementType.WATER, 20.0),
	]
	for i in range(cards.size()):
		pipeline_bar.set_card_in_slot(i, cards[i])
	
	_update_hp_display()
	
	# Düşman otomatik saldırı sayacı (Başlangıçta KAPALI)
	var attack_timer = Timer.new()
	attack_timer.name = "EnemyAttackTimer"
	attack_timer.wait_time = 3.0
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_enemy_attack_pressed)
	add_child(attack_timer)

func _update_hp_display() -> void:
	var cm = get_node("/root/CombatManager")
	%HPBar.max_value = cm.golem_stats.max_hp
	%HPBar.value = cm.golem_stats.current_hp
	
	var golem_label = %HPBar.get_parent().get_node("GolemLabel")
	if golem_label:
		golem_label.text = "GOLEM: %d/%d" % [cm.golem_stats.current_hp, cm.golem_stats.max_hp]
	
	if enemy and enemy.stats:
		%EnemyHPBar.max_value = enemy.stats.max_hp
		%EnemyHPBar.value = enemy.stats.current_hp
		var enemy_label = %EnemyHPBar.get_parent().get_node("EnemyNameLabel")
		if enemy_label and enemy.enemy_data:
			enemy_label.text = "%s: %d/%d" % [enemy.enemy_data.enemy_name, enemy.stats.current_hp, enemy.stats.max_hp]

func _make_card(card_name: String, type: AEnums.CardType,
				element: AEnums.ElementType, value: float) -> CardData:
	var card = CardData.new()
	card.card_name = card_name
	card.card_type = type
	card.element = element
	card.base_value = value
	return card

func _on_start_pressed() -> void:
	_update_hp_display()
	var timer = get_node_or_null("EnemyAttackTimer")
	if timer:
		timer.start()
	pipeline_bar.start_pipeline()
	%StartButton.visible = false # Başlayınca butonu gizle

func _on_enemy_attack_pressed() -> void:
	_combat_manager.golem_take_damage(15.0)
	_update_hp_display()

func _on_run_ended(_floor_reached: int, _loot: Dictionary) -> void:
	var _game_manager = get_node("/root/GameManager")
	var _player_inv = get_node("/root/PlayerInventory")
	var _event_bus = get_node("/root/EventBus")
	var _save_system = get_node("/root/SaveSystem")

	var duration = (Time.get_ticks_msec() / 1000.0) - run_start_time
	_game_manager.record_run(current_floor, duration)
	_game_manager.total_kills += 1

	if _game_manager.daily_challenge_active:
		var _daily = get_node("/root/DailyChallengeManager")
		_daily.complete_challenge()
		_game_manager.daily_challenge_active = false

	# Ganimet hesapla ve ekle
	var reward_mult = 1.0
	_player_inv.add_resource("iron_ore", int(randi_range(5, 15) * reward_mult))
	_player_inv.add_resource("crystal", int(randi_range(1, 5) * reward_mult))
	if randf() < 0.15:
		_player_inv.add_resource("aether_shard", 1)

	# Mastery XP
	for element in _game_manager.mastery_levels:
		_event_bus.mastery_xp_gained.emit(element, 5)

	if _save_system:
		_save_system.save_all()

	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/lab/laboratory_screen.tscn")
