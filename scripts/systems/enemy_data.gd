class_name EnemyData
extends Resource

@export var enemy_name: String = ""
@export var emoji: String = "👹"
@export var enemy_type: AEnums.EnemyType = AEnums.EnemyType.RUNNER
@export var base_hp: float = 100.0
@export var base_damage: float = 10.0
@export var base_defense: float = 0.0
@export var move_speed: float = 1.0
@export var weak_to: Array[AEnums.ElementType] = []
@export var strong_against: Array[AEnums.ElementType] = []
@export var ganimet_multiplier: float = 1.0
@export var description: String = ""
