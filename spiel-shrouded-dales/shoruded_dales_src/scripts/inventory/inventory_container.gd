extends PanelContainer

@export var new_slot: PackedScene

@export var _item_grid: GridContainer
@onready var item_grid: GridContainer = _item_grid


func set_inventory(inventory: Inventory) -> void:
	inventory.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory)
	print("Inventory set")
	

func clear_inventory(inventory: Inventory) -> void:
	inventory.inventory_updated.disconnect(populate_item_grid)
	print("Inventory cleared")
	

func populate_item_grid(inventory: Inventory) -> void:
	for child in item_grid.get_children():
		child.queue_free()
	
	var slot_amount = 0
	
	for slot_data in inventory.content:
		var slot = new_slot.instantiate()
		item_grid.add_child(slot)
		slot_amount += 1
		
		slot.slot_clicked.connect(inventory.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
		
		if not slot_data:
			set_inventory_slot_background(inventory, slot, slot_amount)
	

func set_inventory_slot_background(inventory, slot, index):
	var rect_location: Vector2i
	var rect_grid: Vector2i = Vector2i(32, 32)
	
	if inventory is HotbarInventory:
		rect_location = Vector2i(rect_grid.x * index, 0 * rect_grid.y)
	elif inventory is EquipmentInventory:
		rect_location = Vector2i(rect_grid.x * index, 1 * rect_grid.y)
	
#	for more backgrounds adjust inventory_slot_background.png 
#	elif inventory is InventoryType:
#		rect_location = Vector2i(rect_grid.x * index, #texture_row * rect_grid.y)
	
	slot.slot_texture.region_rect = Rect2i(rect_location, rect_grid)
		
