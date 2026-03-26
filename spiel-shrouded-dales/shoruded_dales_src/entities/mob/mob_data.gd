class_name Mob
extends Entity

#Combat
@export_range(0,999) var max_health: float
@export_range(0,999) var current_health: float
@export var base_attack: int
#Movement
@export var walk_speed: int
#@export var can_fly: bool
