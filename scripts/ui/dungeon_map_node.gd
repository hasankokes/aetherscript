class_name DungeonMapNode
extends Button

signal node_selected(data: DungeonNodeData)

@onready var icon_label: Label = %IconLabel
@onready var type_label: Label = %TypeLabel
@onready var select_glow: ColorRect = $SelectGlow

var node_data: DungeonNodeData = null

func setup(data: DungeonNodeData) -> void:
	node_data = data
	
	match data.node_type:
		DungeonNodeData.NodeType.COMBAT:
			icon_label.text = "👹"
			type_label.text = "BATTLE"
		DungeonNodeData.NodeType.ELITE:
			icon_label.text = "💀"
			type_label.text = "ELITE"
		DungeonNodeData.NodeType.BOSS:
			icon_label.text = "🐲"
			type_label.text = "BOSS"
		DungeonNodeData.NodeType.REST:
			icon_label.text = "☕"
			type_label.text = "REST"
		DungeonNodeData.NodeType.SHOP:
			icon_label.text = "💰"
			type_label.text = "SHOP"
		DungeonNodeData.NodeType.MYSTERY:
			icon_label.text = "❓"
			type_label.text = "EVENT"
	
	# Erişilebilirlik ve tamamlanma durumunu burada basitçe ayarla
	# (İleride GameManager'dan kontrol edilebilir)
	modulate = Color.WHITE
	disabled = false
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	node_selected.emit(node_data)
