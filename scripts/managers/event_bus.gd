extends Node

# Pipeline signals
@warning_ignore("unused_signal")
signal pipeline_card_activated(card_data: CardData, slot_index: int)
@warning_ignore("unused_signal")
signal instruction_pointer_moved(new_index: int)

# Combat signals
@warning_ignore("unused_signal")
signal enemy_damaged(damage: float, element: AEnums.ElementType)
@warning_ignore("unused_signal")
signal golem_hp_changed(new_hp: float, max_hp: float)
@warning_ignore("unused_signal")
signal golem_died()

# Progression signals
@warning_ignore("unused_signal")
signal mastery_xp_gained(element: AEnums.ElementType, amount: int)
@warning_ignore("unused_signal")
signal combo_counter_changed(count: int, element: AEnums.ElementType)
@warning_ignore("unused_signal")
signal run_ended(floor_reached: int, loot: Dictionary)

# Synergy signals
@warning_ignore("unused_signal")
signal synergy_triggered(synergy_id: String)

# Mobile adaptation signals
@warning_ignore("unused_signal")
signal screen_resized(new_size: Vector2)
