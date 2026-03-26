class_name PlayerStateMachine
extends StateMachine


var debug:bool = false


func _ready():
	for child in get_children():
		if child is State:
			states_new[child.name.to_lower()] = child
			# feed information to the states
			child.actor = actor
			child.playback = animation_tree["parameters/playback"]
		else:
			push_warning("Child " + child.name + " is not a State for the player_StateMachine")
	connect_to_signals()
	if current_state:
		current_state.on_enter()


func connect_to_signals()->void:
	SignalManager.change_to_next_state.connect(_on_child_transition)
	SignalManager.take_damage.connect(_on_damage_signal)
	SignalManager.kill_target.connect(_on_kill_signal)


func _physics_process(delta):
	actor.player_input()
	
	# old version state machine
	if current_state.next_state != null:
		change_state(current_state.next_state)

	if debug:
		print_debug(current_state)

	current_state.state_process(delta)

# new version state machine
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
	if debug:
		print("Player detects damage: ", target)
	if target == actor:
		SignalManager.emit_signal("change_to_next_state", current_state, "idle")
		current_state.playback.travel("hurt")
		SignalManager.change_audio.emit("impact_hit","SFX")

func _on_kill_signal(target:Node2D):
	if target == actor:
		if debug:
			print("HERO dIEDED!!!")
		current_state.playback.travel("death")
		if actor.hitbox:
			actor.set_collision_layer_value(2,false)
			actor.set_collision_mask_value(4,false)
		actor.respawn_timer.start(actor.respawn_time)
		actor.velocity = Vector2.ZERO
		
		#SignalManager


func _on_respawn_timer_timeout():
	change_state(states_new.get("idle"))
	current_state.playback.travel("move")

