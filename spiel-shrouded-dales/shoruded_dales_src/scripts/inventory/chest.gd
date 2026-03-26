extends StaticBody2D

signal toggle_inventory(external_inventory_owner)
signal close_external_inventory()

@export var inventory: Inventory
var player_in_range: bool = false
var chest_selected: bool = false

func _ready():
	SignalManager.interact_with.connect(player_interact)
	if not inventory:
		create_inventory()
	

func create_inventory():
#	create new instance of resource inventory to declair inventory sizes and co. automaticly
	pass
	

func player_interact() -> void:
	if player_in_range and chest_selected:
		toggle_inventory.emit(self)
#		print("interact with external Inventory")
	

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		player_in_range = true
#		print(body, " entered chest area")
	

func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		player_in_range = false
		close_external_inventory.emit(self)
#		print(body, " exited chest area")
	

func _on_mouse_entered():
	chest_selected = true
#	print("chest selected")
	

func _on_mouse_exited():
	chest_selected = false
#	print("chest no longer selected")
	
