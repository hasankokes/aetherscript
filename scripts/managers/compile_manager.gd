extends Node

# Aktif compile işlemleri: card_id → başlangıç zamanı
var active_compiles: Dictionary = {}

# Mutasyon havuzu — element bazlı
const MUTATIONS = {
	AEnums.ElementType.FIRE: [
		{
			"id": "pyroclast",
			"name": "Pyroclast",
			"description": "Hasar -%10 ama 2 düşmana sıçrar.",
		},
		{
			"id": "inferno_core",
			"name": "Inferno Core",
			"description": "Her 3 vuruşta garantili yanma efekti.",
		},
	],
	AEnums.ElementType.WATER: [
		{
			"id": "frost_touch",
			"name": "Frost Touch",
			"description": "Her vuruşta %20 yavaşlatma şansı.",
		},
		{
			"id": "tidal_surge",
			"name": "Tidal Surge",
			"description": "Combo x3+ iken hasar iki katına çıkar.",
		},
	],
	AEnums.ElementType.EARTH: [
		{
			"id": "thorned_wall",
			"name": "Thorned Wall",
			"description": "Hasar alan düşman geri hasar alır.",
		},
		{
			"id": "tremor",
			"name": "Tremor",
			"description": "Her 5 vuruşta tüm düşmanlara %30 hasar.",
		},
	],
	AEnums.ElementType.AIR: [
		{
			"id": "phantom_blade",
			"name": "Phantom Blade",
			"description": "Kritik çarparsa imleç 1 kart geri döner.",
		},
		{
			"id": "wind_echo",
			"name": "Wind Echo",
			"description": "Pipeline döngüsü tamamlanınca bonus hasar.",
		},
	],
	AEnums.ElementType.NEUTRAL: [
		{
			"id": "overcharge",
			"name": "Overcharge",
			"description": "Etki +%50 ama cooldown +%30.",
		},
	],
}

signal compile_completed(card: AetherCard)
signal compile_progress_updated(card: AetherCard, progress: float)

func _get_compile_speed() -> float:
	var base = 1.0 + (get_node("/root/GameManager").hardware_levels.get("cpu_speed", 1) - 1) * 0.2
	if get_node("/root/GolemManager").active_personality:
		base *= get_node("/root/GolemManager").active_personality.compile_speed_multiplier
	return base

func start_compile(card: AetherCard) -> bool:
	if not card.can_compile():
		return false

	var cost = card.get_compile_cost()
	for resource_id in cost:
		if not get_node("/root/PlayerInventory").has_resource(
				resource_id, cost[resource_id]):
			print("Yetersiz kaynak: ", resource_id)
			return false

	# Kaynakları harca
	for resource_id in cost:
		get_node("/root/PlayerInventory").spend_resource(
			resource_id, cost[resource_id])

	# Compile başlat
	card.is_compiling   = true
	card.compile_start_time = int(int(Time.get_unix_time_from_system()))
	card.compile_time   = card.get_compile_time()
	card.compile_progress = 0.0

	var card_key = _card_key(card)
	active_compiles[card_key] = card

	get_node("/root/SaveSystem").save_all()
	print("Compile başlatıldı: ", card.card_name)
	return true

func _process(_delta: float) -> void:
	var completed = []
	for key in active_compiles:
		var card = active_compiles[key]
		if not card.is_compiling:
			completed.append(key)
			continue

		var elapsed = float(int(Time.get_unix_time_from_system()) - card.compile_start_time)
		var speed = _get_compile_speed()
		card.compile_progress = minf((elapsed * speed) / card.get_compile_time(), 1.0)

		compile_progress_updated.emit(card, card.compile_progress)

		if card.compile_progress >= 1.0:
			completed.append(key)
			_finish_compile(card)

	for key in completed:
		active_compiles.erase(key)

func _finish_compile(card: AetherCard) -> void:
	card.is_compiling = false
	card.compile_progress = 1.0

	var _proc_audio = get_node("/root/ProceduralAudio")
	if _proc_audio:
		_proc_audio.play_sfx_compile_complete()

	# Tier yükselt
	match card.tier:
		AEnums.CardTier.TIER_1:
			card.tier = AEnums.CardTier.TIER_2
		AEnums.CardTier.TIER_2:
			card.tier = AEnums.CardTier.TIER_3
			# Tier 3te mutasyon ver
			_assign_mutation(card)

	compile_completed.emit(card)
	get_node("/root/SaveSystem").save_all()
	print("Compile tamamlandı: %s -> %s" % [
		card.card_name, card.get_tier_label()])

func _assign_mutation(card: AetherCard) -> void:
	var pool = MUTATIONS.get(card.element,
		MUTATIONS[AEnums.ElementType.NEUTRAL])
	if pool.is_empty():
		return
	var mutation = pool[randi() % pool.size()]
	card.mutation_id          = mutation["id"]
	card.mutation_description = mutation["description"]
	print("Mutasyon atandı: ", mutation["name"])

func check_offline_compiles() -> void:
	# Uygulama kapalıyken geçen süreyi hesapla
	for card in get_node("/root/PlayerInventory").owned_cards:
		if not card.is_compiling:
			continue
		var elapsed = float(int(Time.get_unix_time_from_system()) - card.compile_start_time)
		var speed = _get_compile_speed()
		card.compile_progress = minf((elapsed * speed) / card.get_compile_time(), 1.0)
		if card.compile_progress >= 1.0:
			_finish_compile(card)
		else:
			var card_key = _card_key(card)
			active_compiles[card_key] = card

func _card_key(card: AetherCard) -> String:
	return "%s_%s_%d" % [
		card.card_name, card.element, card.tier]
