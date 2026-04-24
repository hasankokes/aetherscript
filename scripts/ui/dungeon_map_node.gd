class_name DungeonMapNode
extends Button

signal node_selected(node_data: DungeonNodeData)

@onready var icon_label: Label      = $Content/IconLabel
@onready var type_label: Label      = $Content/TypeLabel
@onready var select_glow: ColorRect = $SelectGlow

var node_data: DungeonNodeData = null

const NODE_COLORS = {
	DungeonNodeData.NodeType.COMBAT:  Color(0.8, 0.2, 0.2),
	DungeonNodeData.NodeType.ELITE:   Color(0.6, 0.1, 0.6),
	DungeonNodeData.NodeType.SHOP:    Color(0.2, 0.7, 0.2),
	DungeonNodeData.NodeType.MYSTERY: Color(0.3, 0.3, 0.8),
	DungeonNodeData.NodeType.REST:    Color(0.1, 0.6, 0.6),
	DungeonNodeData.NodeType.BOSS:    Color(0.9, 0.5, 0.0),
}

func setup(data: DungeonNodeData) -> void:
	if not is_node_ready(): await ready
	node_data  = data
	icon_label.text = data.get_icon()
	type_label.text = data.get_display_name()
	modulate = NODE_COLORS.get(data.node_type, Color.WHITE)
	select_glow.visible = false
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	node_selected.emit(node_data)
