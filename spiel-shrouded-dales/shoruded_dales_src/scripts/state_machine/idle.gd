class_name IdleState
extends State

# can travel to following states
@export var move:MoveState
@export var jump:JumpState
@export var fall:FallState
@export var dash:DashState
@export var attack:AttackState

# used animatons
@export var attack_animation : String = "attack"
@export var jump_fall_animation : String = "jump_fall"

func on_enter()->void:
	can_move = true
	actor.can_air_jump = true
	actor.attack_input = false

func state_process(delta)->void:
	actor.gravity(delta)
	actor.movement()
	if actor.movement_input.x != 0:
		SignalManager.emit_signal("change_to_next_state", self, "Move")
#		next_state = move
#		return
	if actor.attack_input:
		playback.travel("attack")
		actor.used_attack = true
		next_state = attack
		return
	if actor.jump_input_actuation:
		actor.jump_input_actuation = false
		next_state = jump
		return
	if actor.dash_input && actor.can_dash:
		next_state = dash
		return
	#in case of trap doors, dissolving ground or falling into level
	if !actor.is_on_floor():
		playback.travel(jump_fall_animation)
		next_state = fall
		return
