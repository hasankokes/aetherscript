extends Node

var golem_stats: Dictionary = {
	"max_hp": 100,
	"current_hp": 100,
	"attack": 10,
	"defense": 5
}
var mastery_damage_bonus: Dictionary = {}
var mastery_crit_bonus: Dictionary = {}
var current_enemy: Node = null
var is_combat_active: bool = false

func _ready():
	_reset_combat_state()

func _reset_combat_state():
	is_combat_active = false
	current_enemy = null

func register_enemy(enemy_node: Node):
	current_enemy = enemy_node
	is_combat_active = true

func golem_take_damage(amount: float):
	var damage = max(0, amount - golem_stats.defense)
	golem_stats.current_hp = max(0, golem_stats.current_hp - damage)
	
	if golem_stats.current_hp <= 0:
		_on_combat_lost()

func golem_heal(amount: float):
	golem_stats.current_hp = min(golem_stats.max_hp, golem_stats.current_hp + amount)

func enemy_take_damage(amount: float):
	if current_enemy and current_enemy.has_method("take_damage"):
		current_enemy.take_damage(amount)

func _on_combat_lost():
	var event_bus = get_node("/root/EventBus")
	event_bus.run_ended.emit(0, {})
	_reset_combat_state()
