extends Control

var mainscreen = load("res://scenes/mainscreen/mainscreen.tscn")

@export var game_manager : GameManager
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	if game_manager:
		game_manager.connect("toggle_pause",_on_game_manager_toggle_pause)


func _on_game_manager_toggle_pause(is_paused:bool):
	if(is_paused):
		if find_parent("UserInterface"):
			if get_parent().inventory_interface.visible:
				get_parent().toggle_inventory_interface()
		show()
	else:
		hide()
	

func _on_resume_button_pressed():
	game_manager.game_paused = false

func _on_exit_button_pressed():
	get_tree().quit()
#	if game_manager.find_parent("Main"):
#		var mainscreen_node = mainscreen.instantiate()
#		game_manager.get_parent().add_child(mainscreen_node)
#		game_manager.game_paused = false
#		game_manager.get_parent().remove_child(game_manager)
#		queue_free()
#

func _on_option_button_pressed():
	self.hide()
	if get_parent():
		var option_menu =get_parent().find_child("Optionmenu")
		if option_menu:
			option_menu.show()


