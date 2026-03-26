# Abstract Template
class_name BaseEnemy
extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Target Information
var target:CharacterBody2D
var target_last_known_position:Vector2
var is_chasing:bool = false
var target_just_lost:bool = false

@export var combat_trigger_area:Area2D
@export var attack_trigger_area:Area2D
@export var attack_hitbox_area:Area2D

func _physics_process(_delta):
	pass
