class_name InstructionPointer
extends Node2D

@onready var pointer_line: ColorRect  = $PointerLine
@onready var pointer_head: Polygon2D  = $PointerHead

var current_element: AetherEnums.ElementType = AetherEnums.ElementType.NEUTRAL
var pulse_tween: Tween = null

func _ready() -> void:
    var _event_bus = get_node("/root/EventBus")
    _event_bus.pipeline_card_activated.connect(_on_card_activated)
    var _aether_theme = get_node("/root/AetherTheme")
    _set_color(_aether_theme.COLOR_PURPLE)

func _on_card_activated(card: CardData, _index: int) -> void:
    current_element = card.element
    var _aether_theme = get_node("/root/AetherTheme")
    var color = _aether_theme.get_element_glow(card.element)
    _set_color(color)
    _pulse()

func _set_color(color: Color) -> void:
    pointer_line.color = color
    pointer_head.color = color

func _pulse() -> void:
    if pulse_tween:
        pulse_tween.kill()
    pulse_tween = create_tween()
    pulse_tween.tween_property(self, "scale", Vector2(1.0, 1.3), 0.06)
    pulse_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.06)
