extends RigidBody2D
class_name PickUp

var merge_counter : int = 0

@export var slot_data: InventorySlot

@export var _sprite_2d : Sprite2D
@onready var sprite_2d : Sprite2D = _sprite_2d

func _ready():
	sprite_2d.texture = slot_data.content.texture
	

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		print("body entered " + body.get_class())
		if body.details.inventory.pick_up_slot_data(slot_data):
			queue_free()
			
#	prevent for lag while collecting items (first version)
	if body is PickUp and body != self :
		print("body entered " + body.get_class())
		merge_counter += 1

		if slot_data.can_merge_with(body.slot_data, "fullstack") and merge_counter > 3:
			slot_data.merge_with(body.slot_data)
			for index in body.get_children():
				body.remove_child(index)
				body.queue_free()
			merge_counter = 0
	
