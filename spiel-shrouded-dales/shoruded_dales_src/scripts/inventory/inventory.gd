class_name Inventory
extends Resource

signal inventory_updated(inventory_data: Inventory)
signal inventory_interact(inventory_data: Inventory, slot_index: int, button: int)

@export_range(7, 35, 1, "or_less","or_greater") var max_slots: int
@export var content: Array[InventorySlot]

@export_group("Weight Settings") # currently not used
@export_range(50, 300, 10, "or_greater") var max_weight: float
@export var current_weight: float

func on_slot_clicked(index: int, button: int) -> void:
	if index in range(0, self.max_slots):
		emit_signal("inventory_interact", self, index, button)

func use_item_in_inventory_slot(index: int) -> void:
	var slot_data = content[index]
	
	if not slot_data:
		return
	
	SignalManager.use_item.emit(slot_data)
	
	if slot_data.content is ConsumableItem and not slot_data.content is MagicalSpell:
		slot_data.amount_of_item -= 1
		if slot_data.amount_of_item < 1:
			content[index] = null
	
	inventory_updated.emit(self)
	
	print(slot_data.content)

func select_slot(index: int, state = "fullstack") -> InventorySlot:
	var slot_data: InventorySlot = self.content[index]
	
	if slot_data:
		if state == "fullstack":
			self.content[index] = null
		elif state == "halfstack":
			if slot_data.amount_of_item <= 1:
				self.content[index] = null
			else:
				slot_data = self.content[index].create_new_slot("halfstack")
				
		emit_signal("inventory_updated", self)
		
		return slot_data
	else:
		return null

func increase_selected_amount(selected_slot_data: InventorySlot, index: int) -> InventorySlot:
	var slot_data: InventorySlot = self.content[index]
	
	if slot_data:
		if selected_slot_data.can_merge_with(slot_data):
			selected_slot_data.merge_with(slot_data.create_new_slot())
		if slot_data.amount_of_item < 1:
			self.content[index] = null
	
	emit_signal("inventory_updated", self)
	
	if selected_slot_data.amount_of_item > 0:
		return selected_slot_data
	return null

func decrease_selected_amount(selected_slot_data: InventorySlot, index: int) -> InventorySlot:
	if selected_slot_data.amount_of_item > 1:
		return drop_slot(selected_slot_data, index)
	return selected_slot_data

func drop_slot(selected_slot_data, index, state = "single") -> InventorySlot:
	var slot_data: InventorySlot = self.content[index]
	
	if not slot_data:
		if state == "single":
			self.content[index] = selected_slot_data.create_new_slot()
		elif state == "halfstack":
			self.content[index] = selected_slot_data.create_new_slot("halfstack")
	elif slot_data.can_merge_with(selected_slot_data):
		if state == "single":
			slot_data.merge_with(selected_slot_data.create_new_slot())
		elif state == "halfstack" and slot_data.can_merge_with(selected_slot_data, "halfstack"):
			slot_data.merge_with(selected_slot_data.create_new_slot("halfstack"))
	
	emit_signal("inventory_updated", self)
	
	if selected_slot_data.amount_of_item > 0:
		return selected_slot_data
	return null

func drop_stack(selected_slot_data: InventorySlot, index: int) -> InventorySlot:
	var slot_data: InventorySlot = self.content[index]
	
	var return_slot_data: InventorySlot
	if slot_data and slot_data.can_merge_with(selected_slot_data, "fullstack"):
		slot_data.merge_with(selected_slot_data)
	else: 
		self.content[index] = selected_slot_data
		return_slot_data = slot_data
	
	emit_signal("inventory_updated", self)
	return return_slot_data

func pick_up_slot_data(slot_data: InventorySlot) -> bool:
	
	for index in content.size():
		if content[index] and content[index].can_merge_with(slot_data, "fullstack"):
			content[index].merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	for index in content.size():
		if not content[index]:
			content[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false
