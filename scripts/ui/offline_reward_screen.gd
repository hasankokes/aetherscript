extends Control

@onready var time_label: Label           = $Panel/TimeLabel
@onready var reward_container: VBoxContainer = $Panel/RewardContainer
@onready var efficiency_label: Label     = $Panel/EfficiencyLabel
@onready var claim_button: Button        = $Panel/ClaimButton

var pending_rewards: Dictionary = {}

func setup(offline_seconds: float) -> void:
    if offline_seconds < 60.0:
        queue_free()
        return

    var efficiency = GameManager.get_average_efficiency()
    var raw_gain   = efficiency * (offline_seconds / 60.0) \
                     * GameManager.offline_multiplier

    # Kazanım hesapla
    pending_rewards = {
        "iron_ore":    int(raw_gain * 8.0),
        "crystal":     int(raw_gain * 3.0),
        "aether_shard": int(raw_gain * 0.5),
    }

    # Süreyi formatla
    var hours   = int(offline_seconds / 3600)
    var minutes = int(fmod(offline_seconds, 3600.0) / 60.0)
    if hours > 0:
        time_label.text = "%d saat %d dakika boyunca..." % [hours, minutes]
    else:
        time_label.text = "%d dakika boyunca..." % minutes

    efficiency_label.text = "Verimlilik: %.1f kat/dak × %.1fx çarpan" % [
        efficiency, GameManager.offline_multiplier]

    # Ödül etiketlerini doldur
    for child in reward_container.get_children():
        child.queue_free()

    var emojis = {
        "iron_ore": "⛏️ Demir Cevheri",
        "crystal": "💎 Kristal",
        "aether_shard": "✨ Aether Parçası"
    }
    for resource_id in pending_rewards:
        var amount = pending_rewards[resource_id]
        if amount <= 0:
            continue
        var lbl = Label.new()
        lbl.text = "%s: +%d" % [emojis.get(resource_id, resource_id), amount]
        lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        reward_container.add_child(lbl)

func _on_claim_button_pressed() -> void:
    for resource_id in pending_rewards:
        PlayerInventory.add_resource(resource_id, pending_rewards[resource_id])
    var _save_system = get_node("/root/SaveSystem")
    _save_system.save_all()
    queue_free()
