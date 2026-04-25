extends Node

var golem_stats: Dictionary = {
	"max_hp": 100,
	"current_hp": 100,
	"attack": 10,
	"defense": 5
}
var mastery_damage_bonus: Dictionary = {
	AEnums.ElementType.FIRE: 1.0,
	AEnums.ElementType.WATER: 1.0,
	AEnums.ElementType.EARTH: 1.0,
	AEnums.ElementType.AIR: 1.0,
	AEnums.ElementType.NEUTRAL: 1.0
}
var golem_damage_multiplier: Dictionary = {
	AEnums.ElementType.FIRE: 1.0,
	AEnums.ElementType.WATER: 1.0,
	AEnums.ElementType.EARTH: 1.0,
	AEnums.ElementType.AIR: 1.0,
	AEnums.ElementType.NEUTRAL: 1.0
}
var mastery_crit_bonus: Dictionary = {
	AEnums.ElementType.FIRE: 0.0,
	AEnums.ElementType.WATER: 0.0,
	AEnums.ElementType.EARTH: 0.0,
	AEnums.ElementType.AIR: 0.0,
	AEnums.ElementType.NEUTRAL: 0.0
}
var damage_reduction: float = 0.0
var crit_mode: bool = false
var current_enemy: Node = null
var is_combat_active: bool = false

func _ready():
	_setup_golem()
	_reset_combat_state()
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.pipeline_card_activated.connect(_on_card_activated)

func _on_card_activated(card: CardData, _slot_index: int) -> void:
	print("CombatManager: Card activated: ", card.card_name)
	if not is_combat_active: 
		print("CombatManager: Combat not active!")
		return
	
	match card.card_type:
		AEnums.CardType.ACTION:
			enemy_take_damage(card.base_value, card.element)
		AEnums.CardType.LOGIC:
			# Basit bir mantık: Eğer can %30 altındaysa iyileştir (kart açıklamasındaki gibi)
			if golem_stats.current_hp < golem_stats.max_hp * 0.3:
				golem_heal(card.base_value)

func _setup_golem() -> void:
	# Başlangıç değerlerini EventBus üzerinden yayınla
	var eb = get_node_or_null("/root/EventBus")
	
	await get_tree().process_frame
	if eb:
		eb.golem_hp_changed.emit(golem_stats.current_hp, golem_stats.max_hp)

func _reset_combat_state():
	is_combat_active = false
	current_enemy = null

func register_enemy(enemy_node: Node):
	current_enemy = enemy_node
	is_combat_active = true

func golem_take_damage(amount: float):
	var damage = max(0, amount - golem_stats.defense)
	golem_stats.current_hp = max(0, golem_stats.current_hp - damage)
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.golem_hp_changed.emit(golem_stats.current_hp, golem_stats.max_hp)
	
	if golem_stats.current_hp <= 0:
		_on_combat_lost()

func golem_heal(amount: float):
	golem_stats.current_hp = min(golem_stats.max_hp, golem_stats.current_hp + amount)
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.golem_hp_changed.emit(golem_stats.current_hp, golem_stats.max_hp)

func enemy_take_damage(amount: float, element: AEnums.ElementType = AEnums.ElementType.NEUTRAL):
	if current_enemy and current_enemy.has_method("receive_damage"):
		current_enemy.receive_damage(amount, element)

func _on_combat_lost():
	var event_bus = get_node("/root/EventBus")
	event_bus.run_ended.emit(0, {})
	_reset_combat_state()
