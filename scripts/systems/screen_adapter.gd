extends Node

var safe_margin_top: float    = 0.0
var safe_margin_bottom: float = 0.0

func _ready() -> void:
    get_tree().root.size_changed.connect(_on_screen_resized)
    _on_screen_resized()

func _on_screen_resized() -> void:
    var viewport_size = get_viewport().get_visible_rect().size

    if OS.has_feature("mobile"):
        safe_margin_top    = 44.0
        safe_margin_bottom = 34.0

    var _event_bus = get_node("/root/EventBus")
    _event_bus.emit_signal("screen_resized", viewport_size)

func get_safe_rect() -> Rect2:
    var size = get_viewport().get_visible_rect().size
    return Rect2(
        0,
        safe_margin_top,
        size.x,
        size.y - safe_margin_top - safe_margin_bottom
    )
