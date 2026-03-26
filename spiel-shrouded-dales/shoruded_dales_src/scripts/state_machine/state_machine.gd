# abstract Template
class_name StateMachine
extends Node

@export var actor:CharacterBody2D
@export var current_state:State
@export var animation_tree: AnimationTree

var states:Array[State]
var states_new:Dictionary = {}

func _ready():
	pass
			
func _physics_process(_delta):
	pass

func change_state(new_state:State):
	if current_state != null:
		current_state.on_exit()
		current_state.next_state = null
	new_state.previous_state = current_state
	current_state = new_state
	current_state.on_enter()
