extends CharacterBody2D
class_name PlayerCharacter

const debug:bool = false

#Signal for inventory
signal toggle_inventory

# Project gravity
var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity")

# movement
var movement_input : Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.RIGHT
@export var max_speed: float = 300.0
@export var acceleration: float = 30.0
@export var deceleration: float = 40.0 # friction
var dash_speed:float = 1.5 * max_speed
var can_dash:bool = true

# walls and raycast-status
var can_wall_slide:bool = false
var ray_top_right:bool = false
var ray_top_left:bool = false
var ray_bottom_right:bool = false
var ray_bottom_left:bool = false

# new jump calculation
@export var jump_height: float = 4*44 # 4*44 Character height (sprite size: 64*44)
var jump_time :float = 0.5 # jump animation 0.5s
var fall_time : float = 0.5 # fall animation 0.3s + landing 0.2s
var jump_velocity : float = (-2.0 * jump_height) / jump_time
var jump_gravity : float = (2.0 * jump_height) / (jump_time * jump_time)
var fall_gravity : float = (2.0 * jump_height) / (fall_time * fall_time)

# air jump
@export var air_jump_height:float = 2.5*44
var air_jump_velocity : float = (-2.0 * air_jump_height) / jump_time
var can_air_jump:bool = false

# coyote jump
var can_coyote_jump : bool = true

# attacks
var used_dash_attack:bool = false
var used_attack:bool = false
var used_magic_attack:bool = false

# death
@export var respawn_timer: Timer
@export var respawn_time:float = 2.0

# player input
var jump_input : bool = false
var jump_input_actuation : bool = false
var climb_input : bool = false
var dash_input: bool = false
var slide_input:bool = false
var attack_input:bool = false
var cast_magic_input:bool = false

@export  var _details : Player
@onready var details : Player = _details


# nodes
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree:AnimationTree = $AnimationTree
@onready var state_machine = $StateMachine
@onready var raycasts = $Raycasts
@onready var hitbox = $Hitbox
@onready var sword_hitbox = $SwordHitbox



var rays:Array[RayCast2D]


#@export var footstep_timer:Timer

@export var respawn_location: Vector2 = Vector2(40,340)


func _ready():
	# starts animation tree on game start, no perma-running animTree
	animation_tree.active = true
	
	if details:
		max_speed = details.walk_speed
	
	for child in raycasts.get_children():
		if child is RayCast2D:
			rays.append(child)
		else:
			push_warning("Child" + child.name + "is not a RayCast2D for Raycast-Array")


func _physics_process(delta):
	if debug:
		print(position)
		#print_debug(velocity) # DEBUG
		#print(state_machine.current_state) # DEBUG
	gravity(delta)
	move_and_slide()
#	if !movement_input.x == 0 && is_on_floor() && footstep_timer.time_left == 0:
#		footstep_timer.play()
#		if state_machine.current_state is MoveState:
#			SignalManager.play_audio_collection.emit(state_machine.current_state.footsteps_sound)
#	elif footstep_timer.time_left == 0:
#		footstep_timer.wait_time =.5
	update_animation_parameters()


# calculation of vertical velocity and gravity
func gravity(delta)->void:
	velocity.y += calc_gravity() * delta
	# cap falling speed at project gravity-setting
	if velocity.y > gravity_value:
		velocity.y = gravity_value

func calc_gravity()->float:
	if velocity.y < 0.0:
		return jump_gravity
	else:
		return fall_gravity


func update_animation_parameters()->void:
	animation_tree.set("parameters/move/blend_position", movement_input.x)


## INPUT HANDLING
func player_input()->void:
	if is_alive():
		movement_input = Vector2.ZERO
	
		if Input.is_action_pressed("move_right"):
			movement_input.x += 1
		if Input.is_action_pressed("move_left"):
			movement_input.x -= 1
		if Input.is_action_pressed("move_up"):
			movement_input.y -= 1
		if Input.is_action_pressed("move_down"):
			movement_input.y += 1
	
		# jumps
		if Input.is_action_pressed("jump"):
			jump_input = true
		else:
			jump_input = false
		if Input.is_action_just_pressed("jump"):
			jump_input_actuation = true
		else:
			jump_input_actuation = false
	
		# dash
		if Input.is_action_just_pressed("dash"):
			dash_input = true
		else:
			dash_input = false
	
		# slide
		if Input.is_action_just_pressed("slide"):
			slide_input = true
		else:
			slide_input = false
	
		# inventory
		if Input.is_action_just_pressed("inventory"):
			toggle_inventory.emit()
	
		# interact
		if Input.is_action_just_pressed("interact"):
			SignalManager.interact_with.emit()

# combat

func _unhandled_input(_event):
	if is_alive():
		if Input.is_action_just_pressed("attack") && state_machine.current_state != AttackState:
			attack_input = true
		else:
			attack_input = false

#		if Input.is_action_pressed("magic"):
#			cast_magic_input = true
#		else:
#			cast_magic_input = false


## MOVEMENT
func movement()->void:
	if is_alive():
		if movement_input.x != 0:
			# set velocity according to direction & flip sprite
			if movement_input.x > 0:
				velocity.x =  min((velocity.x + acceleration), max_speed)
				sprite_2d.scale.x = scale.y *1
				sword_hitbox.scale.x = scale.y*1
				last_direction = Vector2.RIGHT
			if movement_input.x < 0:
				velocity.x = max((velocity.x - acceleration), - max_speed)
				sprite_2d.scale.x = scale.y *-1
				sword_hitbox.scale.x = scale.y*-1
				last_direction = Vector2.LEFT
		else:
			if velocity.x > 0:
				velocity.x = max((velocity.x - deceleration),0)
			if velocity.x < 0:
				velocity.x = min((velocity.x + deceleration),0)


# wall-slide check
func is_next_to_wall()->Vector2:
	reset_rays()
	for raycast in rays:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if debug:
				print("Raycast colliding: " + raycast.name) # DEBUGGING
			check_individual_raycasts(raycast)
	if ray_top_right && ray_bottom_right:
		return Vector2.RIGHT
	if ray_top_left && ray_bottom_left:
		return Vector2.LEFT
	return Vector2.ZERO

func reset_rays()->void:
	ray_top_right = false
	ray_top_left = false
	ray_bottom_right = false
	ray_bottom_left = false
	
func check_individual_raycasts(raycast:RayCast2D)->void:
	if raycast.target_position.x > 0:
		if raycast.name == "TopRight":
			ray_top_right = true
		if raycast.name == "BottomRight":
			ray_bottom_right = true
	else:
		if raycast.name == "TopLeft":
			ray_top_left = true
		if raycast.name == "BottomLeft":
			ray_bottom_left = true


#func _on_timer_timeout():
#	if !movement_input.x == 0 && is_on_floor():
#		footstep_timer.play()
#		#print(footstep_timer.wait_time)
#		if state_machine.current_state is MoveState:
#			SignalManager.play_audio_collection.emit(state_machine.current_state.footsteps_sound)


func _on_respawn_timer_timeout():
	position = respawn_location
	set_collision_layer_value(2,true)
	set_collision_mask_value(4,true)
	details.current_health = details.max_health
	details.current_mana = details.max_mana
	#stamina
	SignalManager.update_health_bar.emit(details.current_health)
	SignalManager.update_mana_bar.emit(details.current_mana)

func is_alive() -> bool:
	if details.current_health > 0:
		return true
	return false
