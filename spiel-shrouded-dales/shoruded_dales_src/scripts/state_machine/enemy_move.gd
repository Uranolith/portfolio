class_name EnemyMove
extends State

const debug:bool = false

@export var _target_lost_timer:Timer
@onready var target_lost_timer = _target_lost_timer

var time_till_target_lost = 1.2

func on_enter():
	animation.play("enemy_move")
	if actor.target_just_lost and target_lost_timer:
		target_lost_timer.start(time_till_target_lost)

func on_exit():
	animation.stop(true)

func state_process(_delta)->void:
	if debug:
		print(actor.movement_direction) # DEBUG
		print(actor.velocity) #DEBUG
		print("chasing: ", actor.is_chasing) #DEBUG

	# Movement: Avoiding Edges
	if !actor.floor_check.has_overlapping_bodies() \
	or (actor.wall_check.is_colliding() and not actor.wall_check.get_collider() is PlayerCharacter):
		actor.movement_direction *= -1
		
	# Combat: Follow target and Attack
	if actor.target and actor.check_for_target_in_combat_range():
		actor.is_chasing = true
		actor.update_target()
		if actor.check_for_target_in_attack_range():
			SignalManager.emit_signal("change_to_next_state", self, "EnemyAttack")
	actor.movement()


# If target is lost, return to idle
func _on_target_lost_timeout():
	if debug:
		print("Target Lost TIMEOUT -------------")
	if actor.check_for_target_in_combat_range():
		actor.is_chasing = true
	else:
		actor.target_just_lost = false
		actor.target = null
		actor.is_chasing = false
		SignalManager.emit_signal("change_to_next_state", self, "EnemyIdle")


func _on_choose_direction_timer_timeout():
	if actor and randi_range(0, 99) % 2 \
	and not (actor.target and actor.check_for_target_in_combat_range()):
		SignalManager.emit_signal("change_to_next_state", self, "EnemyIdle")
