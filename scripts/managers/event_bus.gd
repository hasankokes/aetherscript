@warning_ignore("unused_signal")
extends Node

# Pipeline signals
signal pipeline_card_activated(card_data: CardData, slot_index: int)
signal instruction_pointer_moved(new_index: int)

# Combat signals
signal enemy_damaged(damage: float, element: AetherEnums.ElementType)
signal golem_hp_changed(new_hp: float, max_hp: float)
signal golem_died()

# Progression signals
signal mastery_xp_gained(element: AetherEnums.ElementType, amount: int)
signal combo_counter_changed(count: int, element: AetherEnums.ElementType)
signal run_ended(floor_reached: int, loot: Dictionary)

# Synergy signals
signal synergy_triggered(synergy_id: String)

# Mobile adaptation signals
signal screen_resized(new_size: Vector2)
