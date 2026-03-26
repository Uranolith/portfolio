extends Node


var item : Item


func use_item(target) -> void:
	if item is UseableItem:
		match [item.effect]:
			["Heal"]:
				pass
			
	
