extends Control

const game = preload("res://scenes/game.tscn")


@export var first_node_in_scene: Node2D

func _on_quit_pressed():
	get_tree().quit()


func _on_option_pressed():
	self.hide()
	if get_parent():
		var option_menu =get_parent().find_child("Optionmenu")
		if option_menu:
			option_menu.show()


func _on_credits_pressed():
	self.hide()
	if get_parent():
		var credits_menu =get_parent().find_child("Creditsmenu")
		if credits_menu:
			credits_menu.show()


func _on_start_pressed():
	
	if first_node_in_scene.find_parent("Main"):
		var game_node = game.instantiate()
		first_node_in_scene.get_parent().add_child(game_node)
		first_node_in_scene.get_parent().remove_child(first_node_in_scene)
		queue_free()
