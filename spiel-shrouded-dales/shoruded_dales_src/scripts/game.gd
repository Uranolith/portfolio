class_name GameManager
extends Node2D

signal toggle_pause(is_paused:bool)

@onready var user_interface = find_child("UserInterface")
@onready var player = find_child("Player")

const pick_up_scene = preload("res://scenes/item/pickup.tscn")

var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		#print("!value: ", !value)
		get_tree().paused = game_paused
		emit_signal("toggle_pause", game_paused)

func _ready():
	user_interface.inventory_interface.drop_inventory_slot.connect(_on_inventory_dropped_item)
	

func _on_inventory_dropped_item(slot_data: InventorySlot):
	var pick_up = pick_up_scene.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.position + (player.last_direction * (48 + randi_range(-10, 10)))
	find_child("Pickups").add_child(pick_up)
	

func _input(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		#print("game_paused before set: ", game_paused)
		game_paused = !game_paused
		#print("game_paused after set: ", game_paused)

