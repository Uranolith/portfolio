class_name EquipmentInventory
extends Inventory

func _ready():
	max_slots = 4


func is_matching_armor(slot_item: Item, index: int) -> bool:
	return (index == 0 and slot_item is Headwear)	\
		or (index == 1 and slot_item is Chestwear)	\
		or (index == 2 and slot_item is Handwear)	\
		or (index == 3 and slot_item is Footwear)
#		or (index == 3 and slot_item is Legwear) \
#		or (index == 4 and slot_item is Footwear)


func drop_stack(selected_slot_data: InventorySlot, index: int) -> InventorySlot:
	if not is_matching_armor(selected_slot_data.content, index):
			return selected_slot_data
		
	return super.drop_stack(selected_slot_data, index)
	


func drop_slot(selected_slot_data, index, _state = "single") -> InventorySlot:
	if not is_matching_armor(selected_slot_data.content, index):
		return selected_slot_data
	
	return super.drop_slot(selected_slot_data, index)
	
