class_name HotbarInventory
extends Inventory


func is_matching_itemtype(slot_item: Item) -> bool:
	return slot_item is ConsumableItem
	

func drop_stack(selected_slot_data: InventorySlot, index: int) -> InventorySlot:
	if not is_matching_itemtype(selected_slot_data.content):
			return selected_slot_data
		
	return super.drop_stack(selected_slot_data, index)
	

func drop_slot(selected_slot_data, index, _state = "single") -> InventorySlot:
	if not is_matching_itemtype(selected_slot_data.content):
		return selected_slot_data
	
	return super.drop_slot(selected_slot_data, index)
	
