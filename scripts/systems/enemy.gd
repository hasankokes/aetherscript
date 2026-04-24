class_name Enemy
extends Node2D

@onready var hp_bar: ProgressBar = %HPBar
@onready var hp_label: Label = %HPLabel
@onready var damage_label: Label = %DamageLabel
@onready var death_effect: GPUParticles2D = %DeathEffect

var stats: CombatStats = CombatStats.new()
var enemy_data: EnemyData = null
var is_dead: bool = false
var _event_bus: Node

func setup(data: EnemyData) -> void:
	_event_bus = get_node("/root/EventBus")
	enemy_data = data
	stats.max_hp = data.base_hp
	stats.current_hp = data.base_hp
	stats.defense = data.base_defense

	# Zayıflık/güç çarpanlarını ayarla
	for weak_element in data.weak_to:
		stats.element_multipliers[weak_element] = 1.5
	for strong_element in data.strong_against:
		stats.element_multipliers[strong_element] = 0.5

	_update_hp_bar()

func receive_damage(amount: float, element: AetherEnums.ElementType) -> void:
	if is_dead:
		return

	var real_damage = stats.take_damage(amount, element)
	_show_damage_number(real_damage, element)
	_update_hp_bar()
	_play_hit_effect(element)          # YENİ SATIR

	_event_bus.enemy_damaged.emit(real_damage, element)

	if stats.is_dead():
		_die()

func _play_hit_effect(element: AetherEnums.ElementType) -> void:
	const HIT_EFFECT = preload("res://scenes/combat/hit_effect.tscn")
	var effect = HIT_EFFECT.instantiate()
	get_parent().add_child(effect)
	effect.play(element, global_position + Vector2(
		randf_range(-20, 20), randf_range(-20, 20)))

func _update_hp_bar() -> void:
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.current_hp
	hp_label.text = "%d / %d" % [int(stats.current_hp), int(stats.max_hp)]

func _show_damage_number(amount: float, element: AetherEnums.ElementType) -> void:
	damage_label.text = "-%d" % int(amount)
	damage_label.visible = true

	# Element rengine göre renk
	var colors = {
		AetherEnums.ElementType.FIRE:    Color(1.0, 0.3, 0.1),
		AetherEnums.ElementType.WATER:   Color(0.1, 0.8, 1.0),
		AetherEnums.ElementType.EARTH:   Color(0.7, 0.5, 0.1),
		AetherEnums.ElementType.AIR:     Color(0.8, 0.95, 1.0),
		AetherEnums.ElementType.NEUTRAL: Color(1.0, 1.0, 1.0),
	}
	damage_label.modulate = colors.get(element, Color.WHITE)

	# Yukarı kayarak yok olan animasyon
	var tween = create_tween()
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 40, 0.6)
	tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): damage_label.visible = false)

func _die() -> void:
	is_dead = true
	death_effect.emitting = true
	_event_bus.run_ended.emit(0, {})  # Placeholder, CombatManager dolduracak

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
