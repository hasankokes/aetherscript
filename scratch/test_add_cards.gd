extends Node

func _ready():
	var lab = get_node("/root/LaboratoryScreen")
	var inv = get_node("/root/PlayerInventory")
	
	if not lab:
		print("LaboratoryScreen not found")
		return
	
	if inv.owned_cards.is_empty():
		print("Inventory is empty")
		return
	
	print("Found %d cards in inventory" % inv.owned_cards.size())
	
	# Add Fireball (usually first)
	var fireball = null
	for card in inv.owned_cards:
		if card.card_name == "Fireball":
			fireball = card
			break
	
	if fireball:
		print("Adding Fireball to pipeline")
		lab._on_card_selected_for_pipeline(fireball)
	
	# Add Hasar x2
	var hasar = null
	for card in inv.owned_cards:
		if card.card_name == "Hasar x2":
			hasar = card
			break
	
	if hasar:
		print("Adding Hasar x2 to pipeline")
		lab._on_card_selected_for_pipeline(hasar)
	
	# Add Aqua Pulse
	var aqua = null
	for card in inv.owned_cards:
		if card.card_name == "Aqua Pulse":
			aqua = card
			break
	
	if aqua:
		print("Adding Aqua Pulse to pipeline")
		lab._on_card_selected_for_pipeline(aqua)
	
	print("Done")
	queue_free()
