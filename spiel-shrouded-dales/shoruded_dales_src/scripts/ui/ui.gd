extends CanvasLayer

@export var _player: CharacterBody2D
@onready var player: CharacterBody2D = _player


@export var _inventory_interface: Control
@onready var inventory_interface = _inventory_interface

@export var _hot_bar: PanelContainer
@onready var hot_bar = _hot_bar

@export var _character_resource: Control
@onready var character_resource = _character_resource

# Interface Setup
func _ready():
	connect_inventory_interface()
	connect_external_inventory_interface()
	set_character_resource_interface()

func connect_inventory_interface():
	if player:
		player.toggle_inventory.connect(toggle_inventory_interface)
		inventory_interface.set_player_inventory(player.details.inventory)
		inventory_interface.set_player_equipment_inventory(player.details.equipment_inventory)
		inventory_interface.set_player_hotbar_inventory(player.details.hotbar_inventory)
		if hot_bar:
			hot_bar.set_inventory_data(player.details.hotbar_inventory)

func connect_external_inventory_interface():
	for every_external_inventory in get_tree().get_nodes_in_group("external_inventories"):
		every_external_inventory.toggle_inventory.connect(toggle_inventory_interface)
		every_external_inventory.close_external_inventory.connect(close_external_inventory)

func set_character_resource_interface():
	if character_resource and player:
		character_resource.health_bar.set_max_value(player.details.max_health)  # (player.character_data.max_health)
		character_resource.mana_bar.set_max_value(player.details.max_mana)    # (player.character_data.max_mana)
		character_resource.stamina_bar.set_max_value(player.details.max_stamina) # (player.character_data.max_stamina)
		
		SignalManager.update_health_bar.emit(player.details.current_health)
		SignalManager.update_mana_bar.emit(player.details.current_mana)
		SignalManager.update_stamina_bar.emit(player.details.current_stamina)


# inventory interface interactions
func toggle_inventory_interface(external_inventory_owner = null):
	if inventory_interface.visible:
		inventory_interface.hide()
		hot_bar.show()
	else:
		inventory_interface.show()
		hot_bar.hide()
	
	if external_inventory_owner and inventory_interface.visible:
		open_external_inventory(external_inventory_owner)
	else:
		close_external_inventory(external_inventory_owner, true)

func close_external_inventory(external_inventory_owner, interface_closed_before: bool = false):
	if external_inventory_owner == inventory_interface.external_inventory_owner:
		if not interface_closed_before and inventory_interface.external_inventory.visible:
			inventory_interface.hide()
			hot_bar.show()
			print("force close inventory")
		
		inventory_interface.clear_external_inventory()
		inventory_interface.external_inventory.hide()
	

func open_external_inventory(external_inventory_owner):
	inventory_interface.set_external_inventory(external_inventory_owner)
	inventory_interface.external_inventory.show()
	

func _on_button_pressed():
	find_child("Alternative").visible = not find_child("Alternative").visible
	find_child("MarginCharacterResources").visible = not find_child("MarginCharacterResources").visible
	pass # Replace with function body.
