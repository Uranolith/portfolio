class_name AttackState
extends State

var debug:bool = true

# can travel to following states
@export var idle:IdleState

# listens to animantion ends
@export var attack_animation: String = "attack"
@export var dash_attack_animation: String = "dash_attack"
@export var move_animation : String = "move"

@export var movement_friction:float = 0.5

@export var sword_hitbox:Area2D

func on_enter():
	if actor.used_attack or actor.used_dash_attack:
		SignalManager.change_audio.emit("sword_attack_1","SFX")
		attack()

func on_exit():
	actor.used_dash_attack = false
	actor.used_attack = false
	actor.used_magic_attack = false

func state_process(delta)->void:
	actor.gravity(delta)
	if actor.is_on_floor():
		actor.velocity.x *= movement_friction

func _on_animation_tree_animation_finished(anim_name):
	if debug:
		print_debug("Animation end: ", anim_name) # DEBUG
	if (anim_name == dash_attack_animation) or (anim_name == attack_animation) or(anim_name == "hurt"):
		playback.travel(move_animation)
		next_state = idle
	if anim_name == "death":
		#SignalManager.HeroDied.emit(actor)
		pass

func attack():
	var bodies:Array = sword_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body is EnemyNormal:
			if debug:
				print("Player Hit Target: ", body)
			SignalManager.take_damage.emit(body, actor)
