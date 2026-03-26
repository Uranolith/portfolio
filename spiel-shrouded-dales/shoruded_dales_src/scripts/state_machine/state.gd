# abstract Template
class_name State
extends Node

@export var can_move:bool = true

var actor:CharacterBody2D
var next_state:State = null
var previous_state:State = null
var playback:AnimationNodeStateMachinePlayback
var animation:AnimationPlayer #new

func on_enter()->void:
	pass
	
func on_exit()->void:
	pass
	
func state_process(_delta)->void:
	pass

func get_previous_state():
	return previous_state
