extends PanelContainer

signal slot_clicked(index: int, button: int)

@export var _texture_rect: TextureRect
@onready var texture_rect: TextureRect = _texture_rect

@export var _amount_label: Label
@onready var amount_label: Label = _amount_label

@export var _slot_texture: Sprite2D
@onready var slot_texture: Sprite2D = _slot_texture

var current_cooldown = 0

func _ready():
	z_index = 1
	

func set_slot_data(slot_data: InventorySlot) -> void:
	var item_data = slot_data.content
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.amount_of_item > 1:
		amount_label.text = "%s" % [slot_data.amount_of_item]
		amount_label.show()
	else:
		amount_label.hide()
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() \
			 and (event.button_index == MOUSE_BUTTON_LEFT \
			 or event.button_index == MOUSE_BUTTON_RIGHT \
			 or event.button_index == MOUSE_BUTTON_MIDDLE \
			 or event.button_index == MOUSE_BUTTON_WHEEL_UP \
			 or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		
		emit_signal("slot_clicked", get_index(), event.button_index)
	
