extends Node

var current_node: DungeonNodeData = null

# Oyuncu kalıcı verileri
var mastery_levels: Dictionary = {
	AetherEnums.ElementType.FIRE: 0,
	AetherEnums.ElementType.WATER: 0,
	AetherEnums.ElementType.EARTH: 0,
	AetherEnums.ElementType.AIR: 0,
}

var hardware_levels: Dictionary = {
	"cpu_speed": 1,
	"ram_capacity": 1,
	"battery": 1,
	"mana_capacity": 1,
}

var pipeline_slots: int = 8
var prestige_count: int = 0
var pure_aether: int = 0
var offline_multiplier: float = 1.0

var daily_challenge_active: bool = false

# İstatistikler
var total_runs: int  = 0
var best_floor: int  = 0
var total_kills: int = 0

# Offline zaman damgası
var last_online_time: float = 0.0

# Ortalama verimlilik (son 5 turun kat/dakika ortalaması)
var run_floor_history: Array[int] = []
var run_time_history: Array[float] = []

func _ready() -> void:
	last_online_time = Time.get_unix_time_from_system()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or \
	   what == NOTIFICATION_APPLICATION_PAUSED:
		last_online_time = Time.get_unix_time_from_system()
		var _save_system = get_node("/root/SaveSystem")
		if _save_system:
			_save_system.save_all()

func record_run(floors_reached: int, run_duration_seconds: float) -> void:
	total_runs += 1
	if floors_reached > best_floor:
		best_floor = floors_reached

	run_floor_history.append(floors_reached)
	run_time_history.append(run_duration_seconds)

	if run_floor_history.size() > 5:
		run_floor_history.pop_front()
		run_time_history.pop_front()

func get_average_efficiency() -> float:
	if run_floor_history.is_empty():
		return 0.5
	var total_floors = 0
	var total_time   = 0.0
	for i in range(run_floor_history.size()):
		total_floors += run_floor_history[i]
		total_time   += run_time_history[i]
	if total_time <= 0:
		return 0.5
	return float(total_floors) / (total_time / 60.0)

func get_pipeline_slot_count() -> int:
	return 8 + (hardware_levels["ram_capacity"] - 1) * 2
