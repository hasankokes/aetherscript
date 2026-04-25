extends Control

@onready var pipeline_bar: PipelineBar = $PipelineBar
@onready var log_label: Label = $LogLabel

func _ready() -> void:
	var _event_bus = get_node("/root/EventBus")
	$StartButton.pressed.connect(_on_start_pressed)
	$StopButton.pressed.connect(_on_stop_pressed)
	# Test kartları oluştur (gerçek asset olmadan)
	_load_test_cards()
	
	# EventBus sinyallerini bağla
	_event_bus.pipeline_card_activated.connect(_on_card_activated)
	_event_bus.instruction_pointer_moved.connect(_on_pointer_moved)

func _load_test_cards() -> void:
	# 5 adet sahte kart oluştur ve pipeline'a yerleştir
	var test_names = ["Fireball", "Hasar x2", "Stone Wall", "Eğer HP<%30", "Aqua Pulse"]
	var test_elements = [
		AEnums.ElementType.FIRE,
		AEnums.ElementType.NEUTRAL,
		AEnums.ElementType.EARTH,
		AEnums.ElementType.NEUTRAL,
		AEnums.ElementType.WATER,
	]
	for i in range(test_names.size()):
		var card = CardData.new()
		card.card_name = test_names[i]
		card.element = test_elements[i]
		pipeline_bar.set_card_in_slot(i, card)

func _on_start_pressed() -> void:
	pipeline_bar.start_pipeline()

func _on_stop_pressed() -> void:
	pipeline_bar.stop_pipeline()

func _on_card_activated(card: CardData, index: int) -> void:
	log_label.text = "► Slot %d aktif: %s" % [index, card.card_name]

func _on_pointer_moved(index: int) -> void:
	print("İmleç → Slot ", index)
