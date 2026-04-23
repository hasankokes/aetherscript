extends Control

@onready var loading_bar: ProgressBar = $LoadingBar
@onready var status_label: Label      = $StatusLabel
@onready var logo_label: Label        = $LogoLabel

func _ready() -> void:
    logo_label.modulate.a = 0.0
    _animate_logo()
    _boot_sequence()

func _animate_logo() -> void:
    var tween = create_tween()
    tween.tween_property(logo_label, "modulate:a", 1.0, 1.2)

func _boot_sequence() -> void:
    await _loading_step("Sistem başlatılıyor...", 0.3)
    await _loading_step("Kayıt dosyası okunuyor...", 0.5)

    var _save_system = get_node("/root/SaveSystem")
    var _game_manager = get_node("/root/GameManager")
    var save_exists = _save_system.load_all()

    await _loading_step("Elementler kalibre ediliyor...", 0.7)
    await _loading_step("Pipeline hazırlanıyor...", 0.9)
    await _loading_step("Hazır.", 1.0)

    await get_tree().create_timer(0.4).timeout

    # Offline kazanç hesapla
    if save_exists and _game_manager.last_online_time > 0:
        var now = Time.get_unix_time_from_system()
        var elapsed = float(now - _game_manager.last_online_time)
        if elapsed > 60.0:
            _show_offline_reward(elapsed)
            return

    _go_to_lab()

func _loading_step(status: String, progress: float) -> Signal:
    status_label.text = status
    var tween = create_tween()
    tween.tween_property(loading_bar, "value", progress, 0.3)
    return get_tree().create_timer(0.4).timeout

func _show_offline_reward(elapsed_seconds: float) -> void:
    const OFFLINE_SCREEN = preload("res://scenes/ui/offline_reward_screen.tscn")
    var screen = OFFLINE_SCREEN.instantiate()
    add_child(screen)
    screen.setup(elapsed_seconds)
    await screen.tree_exited
    _go_to_lab()

func _go_to_lab() -> void:
    var _game_manager = get_node("/root/GameManager")
    var _save_system = get_node("/root/SaveSystem")
    _game_manager.last_online_time = Time.get_unix_time_from_system()
    _save_system.save_all()
    get_tree().change_scene_to_file("res://scenes/lab/laboratory_screen.tscn")
