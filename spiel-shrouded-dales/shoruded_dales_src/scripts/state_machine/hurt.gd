class_name HurtState
extends State

var hurt_animation : String = "hurt"
var move_animation : String = "move"

func on_enter():
	playback.travel(hurt_animation)
	


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hurt":
		playback.travel(move_animation)
		SignalManager.emit_signal("change_to_next_state", self, "Idle")
