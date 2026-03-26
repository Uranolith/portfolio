extends PanelContainer

signal use_hotbar_item(index: int)

const slot_scene = preload("res://scenes/ui/inventory/inventory_slot.tscn")

@export var _h_box_container : HBoxContainer
@onready var quick_slot_container : HBoxContainer = _h_box_container


func set_inventory_data(inventory: Inventory) -> void:
	inventory.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory)
	use_hotbar_item.connect(inventory.use_item_in_inventory_slot)
	

func populate_hot_bar(inventory: Inventory) -> void:
	for child in quick_slot_container.get_children():
		child.queue_free()
	
	for slot_data in inventory.content.slice(0,5):
		var slot = slot_scene.instantiate()
		quick_slot_container.add_child(slot)
		
#		if item should be selectable from hotbar
#		slot.slot_clicked.connect(inventory.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
	

func _unhandled_key_input(event) -> void:
	if visible:
		var hotbar_key_input: String = ("hotbar_slot_%s" % [event.as_text()])
		
		if InputMap.has_action(hotbar_key_input) and Input.is_action_just_pressed(hotbar_key_input):
			use_hotbar_item.emit(str_to_var(event.as_text()) - 1)
			print("use hotbar slot %d signal emited" % [str_to_var(event.as_text())])
