extends Node2D

func _ready():
	SignalManager.play_audio.emit("alexander-nakarada-adventure", "MUSIC")
	
