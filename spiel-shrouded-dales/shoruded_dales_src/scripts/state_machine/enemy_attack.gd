class_name EnemyAttack
extends State

func on_enter():
	animation.play("enemy_attack")
	SignalManager.change_audio.emit("sword_attack_2","SFX")


func on_exit():
	animation.stop(true)


func state_process(_delta)->void:
	if actor.movement_direction.x:
		actor.stop_walking()
	if actor.target:
		actor.update_target()
		if actor.check_attack_succeeded():
			relay_target_hit()


func relay_target_hit():
	print("Enemy Hit: ", actor.target)
	SignalManager.take_damage.emit(actor.target, actor)
	SignalManager.emit_signal("change_to_next_state", self, "EnemyMove")
