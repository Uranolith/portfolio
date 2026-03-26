extends Node2D

var has_enemies: bool = false


#func _physics_process(delta):
#	for child in get_children():
#		if child is Area2D:
#			for body in child.has_overlapping_bodies(


func check_for_player(body) -> bool:
	if body is PlayerCharacter:
		return true
	else:
		return false

func _on_combat_area_bridge_body_entered(body):
	if check_for_player(body):
		print("Player detected bridge")
		SignalManager.change_audio.emit("alexander-nakarada-the-great-battle", "MUSIC")


func _on_cave_area_body_entered(body):
	if check_for_player(body):
		SignalManager.change_audio.emit("alexander-nakarada-soft-interlude", "MUSIC")
		print("Player detected Cave")


func _on_dungeon_area_body_entered(body):
	if check_for_player(body):
		SignalManager.change_audio.emit("alexander-nakarada-halloween-theme-1", "MUSIC")
		print("Player detected Dungeon")

func _on_transition_to_end_body_entered(body):
	if check_for_player(body):
		SignalManager.change_audio.emit("alexander-nakarada-superepic", "MUSIC")
		print("Player detected end")
