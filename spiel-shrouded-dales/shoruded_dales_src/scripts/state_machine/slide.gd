class_name SlideState
extends State

# can travel to following states
@export var idle:IdleState
@export var fall:FallState
@export var jump:JumpState
@export var dash:DashState

# used animations
@export var jump_fall_animation : String = "jump_fall"
@export var slide_animation : String = "slide"
@export var idle_animation : String = "idle"


@export var slide_duration : float = 0.8 # 0.6 "slide" animation time
@export var slide_friction : float = 0.97
@export var wall_slide_friction : float = 0.7

@onready var slide_duration_timer = $SlideDuration

func on_enter()->void:
	if previous_state == dash:
		can_move = false
		playback.travel(slide_animation)
		slide_duration_timer.start(slide_duration)
		#print(self.name) #DEBUG

func on_exit()->void:
	can_move = true
	actor.can_wall_slide = false

func state_process(_delta)->void:
	#print_debug(actor.velocity) # DEBUG
	if previous_state == dash:
		actor.velocity.x *= slide_friction
		
	if previous_state == fall or previous_state == jump:
		actor.velocity.y *= wall_slide_friction
		if actor.is_next_to_wall() == Vector2.ZERO:
			if !actor.is_on_floor():
				playback.travel(jump_fall_animation)
				next_state = fall
				return
			else:
				playback.travel(idle_animation)
				next_state = idle
				return
		elif actor.jump_input_actuation:
			if actor.is_next_to_wall() == Vector2.RIGHT:
				actor.velocity.x = - actor.max_speed
			else:
				actor.velocity.x = actor.max_speed
			next_state = jump


func _on_slide_duration_timeout():
	print("SlideDurationTimer timeout!")
	if actor.is_on_floor():
		next_state = idle
	else:
		next_state = fall
