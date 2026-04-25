class_name DungeonNodeData
extends Resource

enum NodeType { COMBAT, ELITE, SHOP, MYSTERY, REST, BOSS }

@export var node_type: NodeType = NodeType.COMBAT
@export var floor_number: int = 1
@export var enemy_data: EnemyData = null
@export var reward_multiplier: float = 1.0

func get_icon() -> String:
	match node_type:
		NodeType.COMBAT:  return "Savas"
		NodeType.ELITE:   return "Elit"
		NodeType.SHOP:    return "Market"
		NodeType.MYSTERY: return "Gizem"
		NodeType.REST:    return "Kamp"
		NodeType.BOSS:    return "Patron"
	return "?"

func get_display_name() -> String:
	match node_type:
		NodeType.COMBAT:  return "Savas Odasi"
		NodeType.ELITE:   return "Elit Dusman"
		NodeType.SHOP:    return "Magaza"
		NodeType.MYSTERY: return "Gizem Odasi"
		NodeType.REST:    return "Dinlenme"
		NodeType.BOSS:    return "Patron"
	return "?"
