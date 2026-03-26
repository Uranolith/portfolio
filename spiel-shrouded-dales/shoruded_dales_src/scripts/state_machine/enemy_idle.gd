class_name EnemyIdle
extends State

@export var idle_duration:float = 3.0
@export var _idle_enought_timer : Timer
@onready var idle_enough_timer:Timer = _idle_enought_timer


func on_enter():
	animation.play("enemy_idle")
	idle_enough_timer.start(idle_duration)


func on_exit():
	animation.stop(true)


func state_process(_delta)->void:
	if actor.movement_direction.x:
		actor.stop_walking()


func _on_idle_enough_timer_timeout():
	if !actor.details.walk_path:
		if randi_range(0, 99) % 2:
			actor.movement_direction *= -1
		SignalManager.emit_signal("change_to_next_state", self, "EnemyMove")
	#else:
	# if actor.details.walk_path:
	# 	if possible return to walk_path
