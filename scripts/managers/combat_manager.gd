extends Node

# Autoload referansları
var _event_bus: Node
var _game_manager: Node

# Golem istatistikleri
var golem_stats: CombatStats = CombatStats.new()
var current_enemy: Enemy = null

# Combo sistemi
var combo_count: int = 0
var last_element: AetherEnums.ElementType = AetherEnums.ElementType.NEUTRAL
var combo_bonus_multiplier: float = 1.0

# Mastery bonus çarpanları (GameManager'dan beslenir)
var mastery_damage_bonus: Dictionary = {
	AetherEnums.ElementType.FIRE:  1.0,
	AetherEnums.ElementType.WATER: 1.0,
	AetherEnums.ElementType.EARTH: 1.0,
	AetherEnums.ElementType.AIR:   1.0,
}

func _ready() -> void:
	_event_bus = get_node("/root/EventBus")
	_game_manager = get_node("/root/GameManager")
	_setup_golem()
	_event_bus.pipeline_card_activated.connect(_on_card_activated)

func _setup_golem() -> void:
	golem_stats.max_hp = 100.0 + (_game_manager.hardware_levels["battery"] - 1) * 20.0
	golem_stats.current_hp = golem_stats.max_hp
	golem_stats.max_mana = 50.0 + (_game_manager.hardware_levels["mana_capacity"] - 1) * 10.0
	golem_stats.mana = golem_stats.max_mana
	_event_bus.golem_hp_changed.emit(golem_stats.current_hp, golem_stats.max_hp)

func register_enemy(enemy: Enemy) -> void:
	current_enemy = enemy

func _on_card_activated(card: CardData, _slot_index: int) -> void:
	var _daily_manager = get_node("/root/DailyChallengeManager")

	if _game_manager.daily_challenge_active:
		if not _daily_manager.is_card_allowed(card):
			return

	if current_enemy == null or current_enemy.is_dead:
		return

	match card.card_type:
		AetherEnums.CardType.ACTION:
			_handle_action_card(card)
		AetherEnums.CardType.MODIFIER:
			_handle_modifier_card(card)
		AetherEnums.CardType.LOGIC:
			_handle_logic_card(card)

func _handle_action_card(card: CardData) -> void:
	# Combo hesapla
	if card.element == last_element and card.element != AetherEnums.ElementType.NEUTRAL:
		combo_count += 1
		_update_combo_bonus()
	else:
		combo_count = 0
		combo_bonus_multiplier = 1.0

	last_element = card.element

	# Hasar hesapla
	var mastery_bonus = mastery_damage_bonus.get(card.element, 1.0)
	var final_damage = card.base_value * mastery_bonus * combo_bonus_multiplier

	# Düşmana uygula
	current_enemy.receive_damage(final_damage, card.element)

	# Mastery XP kazan
	_event_bus.mastery_xp_gained.emit(card.element, 1)

	# Combo sinyali gönder
	_event_bus.combo_counter_changed.emit(combo_count, card.element)

func _handle_modifier_card(card: CardData) -> void:
	# Modifier kartlar bir sonraki ACTION kartın hasarını etkiler
	# Şimdilik: base_value bir sonraki hasar çarpanı olarak kullanılır
	combo_bonus_multiplier *= card.base_value
	print("Modifier aktif: çarpan x", card.base_value)

func _handle_logic_card(card: CardData) -> void:
	# Logic kartlar HP kontrolü yapar
	# Şimdilik temel şartlı kontrol
	var hp_percent = golem_stats.get_hp_percent()
	if hp_percent < 0.3:
		print("Logic tetiklendi: Golem HP kritik!")
		golem_stats.heal(card.base_value)
		_event_bus.golem_hp_changed.emit(golem_stats.current_hp, golem_stats.max_hp)

func _update_combo_bonus() -> void:
	match combo_count:
		2: combo_bonus_multiplier = 1.15
		3: combo_bonus_multiplier = 1.30
		4: combo_bonus_multiplier = 1.50
		_:
			if combo_count >= 5:
				combo_bonus_multiplier = 1.75
	_event_bus.combo_counter_changed.emit(combo_count, last_element)

func golem_take_damage(amount: float) -> void:
	golem_stats.take_damage(amount, AetherEnums.ElementType.NEUTRAL)
	_event_bus.golem_hp_changed.emit(golem_stats.current_hp, golem_stats.max_hp)
	if golem_stats.is_dead():
		_event_bus.run_ended.emit(0, {})
