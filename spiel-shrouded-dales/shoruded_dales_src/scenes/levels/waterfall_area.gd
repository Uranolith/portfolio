extends Node2D

@export var filename: String = "waterfall"
@export var distance: int = 200
@export var filepath: String = "res://assets/soundscape/sfx/"
@export var audioplayer: AudioStreamPlayer2D
@export var active: bool = true

@onready var collision_shape_2d = $Area2D/CollisionShape2D

func _ready():
	collision_shape_2d.shape = CircleShape2D.new()
	collision_shape_2d.shape.radius = distance + 50
	audioplayer.max_distance = distance
	audioplayer.stream = load("%s%s.wav" % [filepath, filename])
	print(collision_shape_2d.shape.radius)

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter and active:
		audioplayer.play()
