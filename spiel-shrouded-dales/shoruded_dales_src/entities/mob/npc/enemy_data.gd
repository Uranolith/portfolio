class_name Enemy
extends Fighter
@export var item_drops: Array[Item]
@export var type: int # -> enum enemy_type(BOSS, ELITE, NORMAL)?
@export_range(.5,3) var difficulty_multiplier: float # maybe global?
