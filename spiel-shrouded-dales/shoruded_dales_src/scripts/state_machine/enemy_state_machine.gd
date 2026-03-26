class_name EnemyStateMachine
extends StateMachine


const debug:bool = false


@export var animation_player:AnimationPlayer

@onready var enemy_idle = $EnemyIdle
@onready var enemy_move = $EnemyMove
@onready var enemy_attack = $EnemyAttack

func _ready():
	for child in get_children():
		if child is State:
			states_new[child.name.to_lower()] = child
			
			# feed information to the states
			child.actor = actor
			child.animation = animation_player
			#child.playback = animation_tree["parameters/playback"]
		else:
			push_warning("Child" + child.name + "is not a State for the player_StateMachine")
	connect_to_signals()
	if current_state:
		current_state.on_enter()

func connect_to_signals()->void:
	SignalManager.change_to_next_state.connect(_on_child_transition)
	SignalManager.take_damage.connect(_on_damage_signal)
	SignalManager.kill_target.connect(_on_kill_signal)


func _physics_process(delta):
	if debug:
		print("SkeletorState: ", current_state) # DEBUG
	if actor and actor.details.current_health > 0:
		if actor.details.current_health < actor.details.max_health:
			actor.health_bar.visible = true
		if !actor.is_on_floor():
			actor.velocity.y += actor.gravity * delta
			change_state(enemy_idle)
		if actor.check_for_target_in_attack_range():
			SignalManager.emit_signal("change_to_next_state", self, "EnemyAttack")
		current_state.state_process(delta)
		actor.move_and_slide()


func _on_child_transition(state, new_state_name):
	if state != current_state:
		return
	var new_state:State = states_new.get(new_state_name.to_lower())
	if !new_state:
		return
	else:
		change_state(new_state)


## COMBAT
# Getting Hurt and Death
func _on_damage_signal(target:Node2D, _agressor:Node2D):
	print(target)
	if target == actor:
		animation_player.play("enemy_hurt")
		SignalManager.change_audio.emit("impact_hit","SFX")

func _on_kill_signal(target:Node2D):
	if target == actor:
		animation_player.play("enemy_death")
	if target is PlayerCharacter:
		target = null
		change_state(enemy_idle)


# Target in Range
func _on_combat_trigger_area_body_entered(body):
	if body is PlayerCharacter:
		if debug:
			print("Player entered area")
		actor.health_bar.visible = true
		actor.target = body
		actor.target_last_known_position = actor.target.get_global_position()
		actor.is_chasing = true
		change_state(enemy_move)


func _on_attack_trigger_area_body_entered(body):
	if debug:
		print("Attack Target")
	if body is PlayerCharacter:
		actor.is_chasing = true
		change_state(enemy_attack)

# Attack-Animation end, follow up on target
func _on_animation_player_animation_finished(anim_name):
	if debug:
		print(anim_name)

	if anim_name == "enemy_attack" or anim_name == "enemy_hurt":
		change_state(enemy_move)

# Target left Area
func _on_combat_trigger_area_body_exited(body):
	if body is PlayerCharacter:
		if debug:
			print("Player left area")
		actor.target_last_known_position = body.get_global_position()
		actor.target_just_lost = true
		actor.is_chasing = false
		#actor.health_bar.visible = false  #turned off due to design-desicion
		change_state(enemy_move)
