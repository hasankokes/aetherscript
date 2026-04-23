extends Button

func _ready() -> void:
    text = "☰"
    custom_minimum_size = Vector2(44, 44)

func _on_pressed() -> void:
    get_tree().paused = not get_tree().paused
    if not get_tree().paused:
        var _save_system = get_node("/root/SaveSystem")
        if _save_system:
            _save_system.save_all()
