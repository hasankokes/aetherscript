class_name PipelineBar
extends VBoxContainer

@onready var slots_container: HBoxContainer = $SlotsContainer
@onready var pointer: Node2D = $PointerContainer/InstructionPointer

var slots: Array[PipelineSlot] = []
var current_slot_index: int = 0
var pointer_speed: float = 1.0       # GameManager'dan alınacak
var time_per_slot: float = 1.0
var elapsed: float = 0.0
var is_running: bool = false

const PIPELINE_SLOT_SCENE = preload("res://scenes/ui/pipeline_slot.tscn")

func _ready() -> void:
	var _game_manager = get_node("/root/GameManager")
	build_pipeline(_game_manager.get_pipeline_slot_count())
	var _event_bus = get_node("/root/EventBus")
	if _event_bus.has_signal("screen_resized"):
		_event_bus.screen_resized.connect(_on_screen_resized)

func _on_screen_resized(new_size: Vector2) -> void:
	_update_slot_sizes(new_size.x)

func _update_slot_sizes(screen_w: float) -> void:
	if slots.is_empty(): return
	var padding = 8.0
	var slot_w = (screen_w - padding * 2) / slots.size()
	slot_w = clampf(slot_w, 44.0, 80.0)
	for slot in slots:
		slot.custom_minimum_size = Vector2(slot_w, 72)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func build_pipeline(slot_count: int) -> void:
	# Mevcut slotları temizle
	for child in slots_container.get_children():
		child.queue_free()
	slots.clear()
	
	# Ekran genişliğine göre slot boyutu hesapla
	var screen_w = get_viewport().get_visible_rect().size.x
	var padding = 8.0
	var slot_w = (screen_w - padding * 2) / slot_count
	slot_w = clampf(slot_w, 44.0, 80.0)

	for i in range(slot_count):
		var slot: PipelineSlot = PIPELINE_SLOT_SCENE.instantiate()
		slot.slot_index = i
		slot.custom_minimum_size = Vector2(slot_w, 72)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slots_container.add_child(slot)
		slots.append(slot)

func start_pipeline() -> void:
	if slots.is_empty(): return
	is_running = true
	current_slot_index = 0
	elapsed = 0.0
	_activate_slot(0)

func stop_pipeline() -> void:
	is_running = false
	for slot in slots:
		slot.deactivate()

func _process(delta: float) -> void:
	if not is_running:
		return
	
	elapsed += delta * pointer_speed
	
	# İmleç görsel pozisyonunu güncelle
	_update_pointer_visual()
	
	if elapsed >= time_per_slot:
		elapsed = 0.0
		_advance_pointer()

func _advance_pointer() -> void:
	if slots.is_empty(): return
	slots[current_slot_index].deactivate()
	
	# Bir sonraki dolu slotu bul
	var next_index = current_slot_index
	var checked = 0
	while checked < slots.size():
		next_index = (next_index + 1) % slots.size()
		checked += 1
		if slots[next_index].current_card != null:
			break
	
	current_slot_index = next_index
	_activate_slot(current_slot_index)
	
	var _event_bus = get_node("/root/EventBus")
	_event_bus.instruction_pointer_moved.emit(current_slot_index)
	
	# Kartta aksiyon tetikle
	var active_card = slots[current_slot_index].current_card
	if active_card:
		_event_bus.pipeline_card_activated.emit(active_card, current_slot_index)

func _activate_slot(index: int) -> void:
	if index < slots.size():
		slots[index].activate()

func _update_pointer_visual() -> void:
	if slots.is_empty():
		return
	var slot_width = slots_container.size.x / slots.size()
	var target_x = current_slot_index * slot_width + slot_width * 0.5
	pointer.position.x = target_x - 2.0

func set_card_in_slot(slot_index: int, card: CardData) -> void:
	if slot_index < slots.size():
		slots[slot_index].set_card(card)

func clear_slot(slot_index: int) -> void:
	if slot_index < slots.size():
		slots[slot_index].set_empty()
