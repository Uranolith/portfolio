class_name MoveState
extends State

# can travel to following states
@export var idle:IdleState
@export var fall:FallState
@export var jump:JumpState
@export var dash:DashState
@export var attack:AttackState

# used animatons
@export var attack_animation : String = "attack"
@export var jump_fall_animation : String = "jump_fall"

@export var footsteps_sound: Array[String] 

func on_enter():
	SignalManager.play_audio_collection.emit(footsteps_sound)

func state_process(delta):
	actor.gravity(delta)

	#actor.movement()

	if (!actor.is_on_floor()):
		playback.travel(jump_fall_animation)
		next_state = fall
		return
	if actor.jump_input_actuation:
		next_state = jump
		return
	actor.movement()
	if actor.attack_input:
		playback.travel(attack_animation)
		actor.used_attack = true
		next_state = attack
		return
	if actor.dash_input && actor.can_dash:
		next_state = dash
		return
	if (actor.velocity.x == 0):
		next_state = idle
		return
