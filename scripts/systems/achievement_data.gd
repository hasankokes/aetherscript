class_name AchievementData
extends Resource

@export var achievement_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var emoji: String = "🏆"
@export var reward_aether: int = 0
@export var reward_resource: Dictionary = {}
@export var is_hidden: bool = false
@export var condition_type: String = ""
@export var condition_value: float = 0.0
