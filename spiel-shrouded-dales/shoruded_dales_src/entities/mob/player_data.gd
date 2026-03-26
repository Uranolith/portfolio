class_name Player
extends Mob

#Stats
@export_range(0,100) var max_stamina: float
@export_range(0,100) var current_stamina: float
@export var max_mana: int
@export var current_mana: int

#Combat
#@export var base_physical_resistance: float
#@export var base_magical_resistance: float

#Equipment
#@export var weapon: Weapon
#@export var helmet: Headwear
#@export var chest: Chestwear
#@export var gloves: Handwear
#@export var legs: Legwear
#@export var boots: Footwear

#UI information
@export var inventory: Inventory
@export var equipment_inventory: EquipmentInventory
@export var hotbar_inventory: HotbarInventory
#@export var credits: int

