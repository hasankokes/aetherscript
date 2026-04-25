class_name GolemPersonalityData
extends Resource

@export var personality_id: String = ""
@export var display_name: String = ""
@export var emoji: String = "🤖"
@export var description: String = ""

# Pasif bonus çarpanları
@export var hp_multiplier: float = 1.0
@export var cpu_speed_multiplier: float = 1.0
@export var fire_damage_multiplier: float = 1.0
@export var water_damage_multiplier: float = 1.0
@export var earth_damage_multiplier: float = 1.0
@export var air_damage_multiplier: float = 1.0
@export var compile_speed_multiplier: float = 1.0

# Dezavantaj açıklaması
@export var disadvantage_text: String = ""

# Açılma koşulu
@export var unlock_condition: String = ""  
# "start", "prestige_1", "mastery_fire_10" vb.
