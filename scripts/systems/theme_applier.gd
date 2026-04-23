extends Node

func _ready() -> void:
	_apply_global_theme()

func _apply_global_theme() -> void:
	# Tüm Label'lar için varsayılan renk
	var theme = Theme.new()

	# Panel arka planı — koyu
	var panel_style = StyleBoxFlat.new()
	var _aether_theme = get_node("/root/AetherTheme")
	panel_style.bg_color         = _aether_theme.COLOR_BG_MID
	panel_style.border_color     = _aether_theme.COLOR_PURPLE
	panel_style.border_width_top    = 1
	panel_style.border_width_bottom = 1
	panel_style.border_width_left   = 1
	panel_style.border_width_right  = 1
	panel_style.corner_radius_top_left     = 6
	panel_style.corner_radius_top_right    = 6
	panel_style.corner_radius_bottom_left  = 6
	panel_style.corner_radius_bottom_right = 6
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# Button stili
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color     = _aether_theme.COLOR_PURPLE_DARK
	btn_normal.border_color = _aether_theme.COLOR_PURPLE
	btn_normal.border_width_top = btn_normal.border_width_bottom = 2
	btn_normal.border_width_left = btn_normal.border_width_right = 2
	btn_normal.corner_radius_top_left     = 4
	btn_normal.corner_radius_top_right    = 4
	btn_normal.corner_radius_bottom_left  = 4
	btn_normal.corner_radius_bottom_right = 4
	theme.set_stylebox("normal", "Button", btn_normal)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = _aether_theme.COLOR_PURPLE
	theme.set_stylebox("hover", "Button", btn_hover)

	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = _aether_theme.COLOR_PURPLE_DARK
	btn_pressed.border_color = _aether_theme.COLOR_GOLD
	theme.set_stylebox("pressed", "Button", btn_pressed)

	theme.set_color("font_color",         "Button", _aether_theme.COLOR_WHITE_SOFT)
	theme.set_color("font_hover_color",   "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", _aether_theme.COLOR_GOLD)
	theme.set_color("font_color",         "Label",  _aether_theme.COLOR_WHITE_SOFT)

	# ProgressBar
	var pb_bg = StyleBoxFlat.new()
	pb_bg.bg_color = _aether_theme.COLOR_BG_DARK
	pb_bg.corner_radius_top_left     = 4
	pb_bg.corner_radius_top_right    = 4
	pb_bg.corner_radius_bottom_left  = 4
	pb_bg.corner_radius_bottom_right = 4
	var pb_fill = StyleBoxFlat.new()
	pb_fill.bg_color = _aether_theme.COLOR_PURPLE
	pb_fill.corner_radius_top_left     = 4
	pb_fill.corner_radius_top_right    = 4
	pb_fill.corner_radius_bottom_left  = 4
	pb_fill.corner_radius_bottom_right = 4
	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill",       "ProgressBar", pb_fill)

	get_tree().root.theme = theme
