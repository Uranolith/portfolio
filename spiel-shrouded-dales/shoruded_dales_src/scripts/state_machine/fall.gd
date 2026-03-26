class_name FallState
extends State

# can travel to following states
@export var idle:IdleState
@export var jump:JumpState
@export var dash:DashState
@export var slide:SlideState
@export var attack:AttackState
@export var move:MoveState

# used animatons
@export var landing_animation: String = "landing"
@export var air_jump_animation : String = "air_jump"
@export var wall_slide_animation : String = "wall_slide"

# coyote time : 'pro player' jump-recognition on edges
@export var coyote_duration : float = 0.2
@onready var coyote_timer : Timer = $CoyoteTimer

var is_landing: bool = false

func on_enter():
	if previous_state == idle || previous_state == move || previous_state == slide:
		actor.can_coyote_jump = true
		coyote_timer.start(coyote_duration)
	else:
		actor.can_coyote_jump = false
	is_landing = false

# removed on_exit():

func state_process(delta):
	actor.gravity(delta)
	actor.movement()
	if actor.is_next_to_wall() != Vector2.ZERO:
		actor.can_wall_slide = true
		playback.travel(wall_slide_animation)
		next_state = slide
		return
	if actor.attack_input:
		playback.travel("attack")
		next_state = attack
		return
	if actor.dash_input && actor.can_dash:
		next_state = dash
		return
	if actor.jump_input_actuation && actor.can_coyote_jump:
		next_state = jump
		return
	if actor.jump_input_actuation && actor.can_air_jump:
		next_state = jump
		return
	if actor.is_on_floor() and is_landing == false:
		landing()
		return


func landing():
	is_landing = true
	can_move = false
	playback.travel(landing_animation)
	SignalManager.change_audio.emit("stone_landing","SFX")


func _on_animation_tree_animation_finished(anim_name):
	if (anim_name == landing_animation):
		next_state = idle

func _on_coyote_timer_timeout():
	actor.can_coyote_jump = false
