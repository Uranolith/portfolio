class_name InventorySlot
extends Resource

@export var content: Item
@export var amount_of_item: int = 1: set = set_amount_of_item


func can_merge_with(other_slot_data: InventorySlot, state : String = "single") -> bool:
	var return_value : bool
	
	if state == "single":
		return_value = self.content == other_slot_data.content and self.content.stack_size > 1 and self.amount_of_item < self.content.stack_size
	if state == "halfstack":
		return_value = self.can_merge_with(other_slot_data) and self.amount_of_item + round(other_slot_data.amount_of_item * .5) <= self.content.stack_size
	elif state == "fullstack":
		return_value = self.can_merge_with(other_slot_data) and self.amount_of_item + other_slot_data.amount_of_item <= self.content.stack_size
	return return_value


func merge_with(other_slot_data: InventorySlot) -> void:
	self.amount_of_item += other_slot_data.amount_of_item


func create_new_slot(state: String = "single") -> InventorySlot:
	var new_slot_data : InventorySlot = self.duplicate()
	if state == "single":
		new_slot_data.amount_of_item = 1
		self.amount_of_item -= 1
	elif state == "halfstack":
		new_slot_data.amount_of_item = round(self.amount_of_item * .5)
		self.amount_of_item -= new_slot_data.amount_of_item
	return new_slot_data


func set_amount_of_item(value: int) -> void:
	amount_of_item = value
	if amount_of_item > self.content.stack_size:
		amount_of_item = self.content.stack_size

