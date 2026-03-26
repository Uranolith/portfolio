extends Control

signal drop_inventory_slot(slot_data: InventorySlot)

var selected_slot_data: InventorySlot
var external_inventory_owner

@export var _player_inventory: PanelContainer
@onready var player_inventory: PanelContainer = _player_inventory

@export var _player_qeuipment_inventory: PanelContainer
@onready var player_equipment_inventory: PanelContainer = _player_qeuipment_inventory

@export var _player_hotbar_inventory: PanelContainer
@onready var player_hotbar_inventory: PanelContainer = _player_hotbar_inventory

@export var _external_inventory: PanelContainer
@onready var external_inventory: PanelContainer = _external_inventory

@export var _selected_slot: PanelContainer
@onready var selected_slot: PanelContainer = _selected_slot

## Attach a InventorySlot to the mouse with an offset of +5 in x and y direction
func _physics_process(_delta) -> void:
	if selected_slot.visible:
		selected_slot.global_position = get_global_mouse_position() + Vector2(5,5)
	

func set_player_inventory(inventory: Inventory) -> void:
	inventory.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory(inventory)
	

func set_player_equipment_inventory(inventory: Inventory) -> void:
	inventory.inventory_interact.connect(on_inventory_interact)
	player_equipment_inventory.set_inventory(inventory)
	

func set_player_hotbar_inventory(inventory: Inventory) -> void:
	inventory.inventory_interact.connect(on_inventory_interact)
	player_hotbar_inventory.set_inventory(inventory)
	

func set_external_inventory(inventory_owner) -> void:
	external_inventory_owner = inventory_owner
	
	external_inventory_owner.inventory.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory(external_inventory_owner.inventory)
	

func clear_external_inventory() -> void:
	if external_inventory_owner:
		external_inventory_owner.inventory.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory(external_inventory_owner.inventory)
		external_inventory_owner = null
	

func on_inventory_interact(inventory: Inventory, index: int, button: int) -> void:
	
	match [selected_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			selected_slot_data = inventory.select_slot(index, "fullstack")
		[_, MOUSE_BUTTON_LEFT]:
			selected_slot_data = inventory.drop_stack(selected_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			selected_slot_data = inventory.select_slot(index, "halfstack")
		[_, MOUSE_BUTTON_RIGHT]:
			selected_slot_data = inventory.drop_slot(selected_slot_data, index)
		[null, MOUSE_BUTTON_WHEEL_DOWN]:
			pass
		[_, MOUSE_BUTTON_WHEEL_DOWN]:
			selected_slot_data = inventory.decrease_selected_amount(selected_slot_data, index)
		[null, MOUSE_BUTTON_WHEEL_UP]:
			pass
		[_, MOUSE_BUTTON_WHEEL_UP]:
			selected_slot_data = inventory.increase_selected_amount(selected_slot_data, index)
			
	print("Inventory: %31s \t Slot: %2s \t Button: %1s \t Item: %31s" % [inventory, index, button, selected_slot_data])
	update_selected_slot()
	

func update_selected_slot() -> void:
	if selected_slot_data:
		selected_slot.show()
		selected_slot.set_slot_data(selected_slot_data)
	else:
		selected_slot.hide()
	

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and selected_slot_data:
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_inventory_slot.emit(selected_slot_data)
				selected_slot_data = null
				print ("drop item emitted (stack of item)")
			MOUSE_BUTTON_RIGHT:
				drop_inventory_slot.emit(selected_slot_data.create_new_slot())
				if selected_slot_data.amount_of_item < 1:
					selected_slot_data = null
				print ("drop item emitted (single item)")
			
		update_selected_slot()
