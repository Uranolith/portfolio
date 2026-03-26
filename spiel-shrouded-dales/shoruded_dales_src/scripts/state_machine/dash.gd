class_name DashState
extends State

# can travel to following states
@export var idle:IdleState
@export var fall:FallState
@export var slide:SlideState
@export var attack:AttackState

# used animations
@export var dash_start_animation : String = "dash_start"
@export var dash_end_animation : String = "dash_end"
@export var dash_attack_animation : String = "dash_attack"
@export var jump_fall_animation : String = "jump_fall"

@export var dash_cooldown:float = 0.5
@onready var dash_cooldown_timer = $DashCooldown

var dash_direction:Vector2 = Vector2.ZERO
var dashing: bool = false

func on_enter()->void:
	playback.travel(dash_start_animation)
	dashing = true
	if actor.movement_input != Vector2.ZERO:
		dash_direction = actor.movement_input
	else:
		dash_direction = actor.last_direction
	actor.velocity = dash_direction.normalized() * actor.dash_speed
	SignalManager.change_audio.emit("dash","SFX")


func state_process(_delta):
	if dashing && actor.slide_input && actor.is_on_floor():
		next_state = slide
		return
	if dashing && actor.attack_input && actor.is_on_floor():
		playback.travel(dash_attack_animation)
		actor.used_dash_attack = true
		next_state = attack
		return
	if !dashing && actor.is_on_floor():
		playback.travel(dash_end_animation)
		next_state = idle
	if !dashing && !actor.is_on_floor():
		playback.travel(jump_fall_animation)
		next_state = fall


func _on_dash_cooldown_timeout():
	actor.can_dash = true


# using end of animation instead of timer to prevent unwanted double attack
func _on_animation_tree_animation_finished(anim_name):
	if anim_name == dash_start_animation:
		dashing = false
		dash_cooldown_timer.start(dash_cooldown)
		actor.can_dash = false
