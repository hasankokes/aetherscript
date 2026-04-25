extends Node

# Kat başına HP ve hasar büyüme çarpanı
const HP_SCALE_PER_FLOOR:  float = 0.08   # Her katta %8 HP artışı
const DMG_SCALE_PER_FLOOR: float = 0.05   # Her katta %5 hasar artışı

# Corruption Mode aktifse ekstra çarpan
const CORRUPTION_MULTIPLIER: float = 2.0

# Düşman havuzları — kat aralığına göre
const ENEMY_POOLS = {
	"1-10":  ["goblin", "spore_swarm"],
	"11-20": ["goblin", "stone_golem", "spore_swarm"],
	"21-30": ["stone_golem", "void_witch", "iron_guardian"],
	"31-40": ["void_witch", "iron_guardian"],
	"41-50": ["iron_guardian", "void_witch"],
}

const ELITE_POOL = ["stone_golem", "iron_guardian", "void_witch"]
const BOSS_POOL  = ["aether_drake"]

var _enemy_cache: Dictionary = {}

func get_enemy_for_floor(
		floor_num: int,
		node_type: int) -> EnemyData:

	var base_data = _load_enemy(
		_pick_enemy_id(floor_num, node_type))
	return _scale_enemy(base_data, floor_num)

func _pick_enemy_id(floor_num: int, node_type: int) -> String:
	# Boss
	if node_type == DungeonNodeData.NodeType.BOSS:
		return BOSS_POOL[0]

	# Elite
	if node_type == DungeonNodeData.NodeType.ELITE:
		var idx = randi() % ELITE_POOL.size()
		return ELITE_POOL[idx]

	# Normal savaş — kata göre havuz seç
	var pool_key = _get_pool_key(floor_num)
	var pool = ENEMY_POOLS.get(pool_key,
		ENEMY_POOLS["1-10"])
	return pool[randi() % pool.size()]

func _get_pool_key(floor_num: int) -> String:
	if floor_num <= 10:  return "1-10"
	if floor_num <= 20:  return "11-20"
	if floor_num <= 30:  return "21-30"
	if floor_num <= 40:  return "31-40"
	return "41-50"

func _load_enemy(enemy_id: String) -> EnemyData:
	if _enemy_cache.has(enemy_id):
		return _enemy_cache[enemy_id]
	var path = "res://data/enemies/%s.tres" % enemy_id
	if not ResourceLoader.exists(path):
		push_error("Düşman bulunamadı: " + path)
		return _make_fallback_enemy()
	var data = ResourceLoader.load(path) as EnemyData
	_enemy_cache[enemy_id] = data
	return data

func _scale_enemy(base: EnemyData, floor_num: int) -> EnemyData:
	# Orijinal resource'u değiştirme — kopyasını al
	var scaled = base.duplicate() as EnemyData
	var floor_mult = 1.0 + (floor_num - 1) * HP_SCALE_PER_FLOOR
	var dmg_mult   = 1.0 + (floor_num - 1) * DMG_SCALE_PER_FLOOR

	# Corruption mode
	var corruption = PrestigeManager._has_upgrade(
		"corruption_mode")
	if corruption:
		floor_mult *= CORRUPTION_MULTIPLIER
		dmg_mult   *= CORRUPTION_MULTIPLIER

	scaled.base_hp     = base.base_hp     * floor_mult
	scaled.base_damage = base.base_damage * dmg_mult
	scaled.base_defense = base.base_defense *          (1.0 + (floor_num - 1) * 0.03)

	return scaled

func _make_fallback_enemy() -> EnemyData:
	var fallback = EnemyData.new()
	fallback.enemy_name = "Bilinmeyen Düşman"
	fallback.base_hp     = 100.0
	fallback.base_damage = 10.0
	fallback.emoji       = "❓"
	return fallback
