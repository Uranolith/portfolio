extends Control


func _on_return_button_pressed():
	
	self.hide()
	var calling_menu
	if get_parent():
		if get_parent().find_child("Startmenu"):
			calling_menu = get_parent().find_child("Startmenu")
			calling_menu.show()
