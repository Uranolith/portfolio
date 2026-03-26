class_name EnemyNormal
extends BaseEnemy

const debug:bool = true

@export var floor_check:Area2D
@export var wall_check:RayCast2D
@export var flip_node:Node2D

@export var health_bar:ProgressBar

@export  var _details : Enemy
@onready var details : Enemy = _details

@onready var enemy_state_machine = $EnemyStateMachine
#@onready var animation_player:AnimationPlayer = $AnimationPlayer #new


var movement_direction:Vector2 = Vector2.RIGHT:
	set(new_direction):
		if(movement_direction != new_direction):
			movement_direction = new_direction
			flip_node.scale.x = new_direction.x
var ground_in_front : bool = true

func _ready():
	SignalManager.update_enemy_health_bar.connect(_on_update_health_bar)
	
	if health_bar:
		health_bar.set_max_value(details.max_health)
		health_bar.visible = false

func _on_update_health_bar(_target: Node2D):
	if _target == self:
		health_bar.value = health_bar.max_value - _target.details.current_health


func movement()->void:
	if details:
		if movement_direction.x:
			start_walking()
		else:
			stop_walking()

func start_walking()->void:
	velocity.x =  movement_direction.x * details.walk_speed
func stop_walking()->void:
	velocity.x = move_toward(velocity.x,0,details.walk_speed)


## Target detection
func get_target_position()->Vector2:
	return target.get_global_position()


func check_for_target_in_combat_range()->bool:
	for body in combat_trigger_area.get_overlapping_bodies():
		if body is PlayerCharacter:
			return true
	return false


func check_for_target_in_attack_range()->bool:
	for body in attack_trigger_area.get_overlapping_bodies():
		if body is PlayerCharacter:
			return true
	return false


func face_target_direction()->void:
	if position.x > target_last_known_position.x:
		movement_direction = Vector2.LEFT
	else:
		movement_direction = Vector2.RIGHT


func update_target():
		target_last_known_position = target.get_global_position()
		if position.distance_to(get_target_position()) > 40:
			stop_walking()
			face_target_direction()


## Attack status
func check_attack_succeeded()->bool:
	for body in attack_hitbox_area.get_overlapping_bodies():
		if body is PlayerCharacter:
			return true
	return false

# testen
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "enemy_death":
		get_parent().remove_child(self)
		queue_free()
