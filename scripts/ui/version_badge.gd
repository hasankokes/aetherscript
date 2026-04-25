extends CanvasLayer

func _ready() -> void:
	var lbl = Label.new()
	lbl.text = "v0.1 Alpha"
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	lbl.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	lbl.position = Vector2(-10, -10)
	add_child(lbl)
