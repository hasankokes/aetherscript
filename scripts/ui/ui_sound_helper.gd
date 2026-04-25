class_name UISoundHelper
extends Node

static func add_click_sound(button: Button) -> void:
	button.pressed.connect(func():
		if not button.is_inside_tree(): return
		var _proc_audio = button.get_node_or_null("/root/ProceduralAudio")
		if _proc_audio:
			_proc_audio.play_sfx_ui_click()
	)

static func add_sounds_to_all_buttons(root: Node) -> void:
	for node in _get_all_buttons(root):
		add_click_sound(node)

static func _get_all_buttons(node: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	if node is Button:
		buttons.append(node)
	for child in node.get_children():
		buttons.append_array(_get_all_buttons(child))
	return buttons
