extends State
class_name JumpState

# can travel to following states
@export var fall:FallState
@export var idle:IdleState
@export var dash:DashState
@export var slide:SlideState
@export var attack:AttackState

# used animatons
@export var jump_start_animation : String = "jump_start"
@export var air_jump_animation : String = "air_jump"
@export var wall_slide_animation : String = "wall_slide"

# jump buffer : register input while !can_move and execute asap

func on_enter():
	if previous_state == fall && actor.can_coyote_jump:
		jump()
	elif previous_state == slide:
		jump()
	elif actor.can_air_jump && !actor.is_on_floor():
		air_jump()
	else:
		jump()

func on_exit():
	actor.jump_input_actuation = false

func state_process(delta):
	
	actor.movement()
	actor.gravity(delta)
	if actor.is_next_to_wall() != Vector2.ZERO:
		actor.can_wall_slide = true
		playback.travel(wall_slide_animation)
		next_state = slide
		return
	if actor.attack_input:
		playback.travel("attack")
		actor.used_attack = true
		next_state = attack
		return
	if actor.dash_input && actor.can_dash:
		next_state = dash
		return
	if actor.jump_input_actuation && actor.can_air_jump:
		actor.jump_input_actuation = false
		air_jump()
		return
	if actor.velocity.y >= 0 && !actor.is_on_floor():
		next_state = fall
		return

func jump():
	#print("jump")
	SignalManager.change_audio.emit("stone_chain_jump","SFX")
	actor.velocity.y = actor.jump_velocity
	playback.travel(jump_start_animation)

func air_jump():
	#print("air jump")
	#SignalManager.change_audio.emit("stone_chain_jump","SFX")
	actor.velocity.y = actor.air_jump_velocity
	playback.travel(air_jump_animation)
	actor.can_air_jump = false
