extends Control
@export var checkbutton_audio: CheckButton

var master_bus=AudioServer.get_bus_index("Master")
var music_bus=AudioServer.get_bus_index("music")
var sfx_bus=AudioServer.get_bus_index("sfx")

@export var sfx_slider: HSlider
@export var music_slider: HSlider

func _ready():
	sfx_slider.value = AudioServer.get_bus_volume_db(sfx_bus)
	music_slider.value = AudioServer.get_bus_volume_db(music_bus)

func _on_h_slider_music_volume_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus,value)
	if value == -30:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)
	

func _on_h_slider_sfx_volume_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus,value)
	if value == -30:
		AudioServer.set_bus_mute(sfx_bus,true)
	else:
		AudioServer.set_bus_mute(sfx_bus,false)
	


func _on_check_button_audio_toggled(button_pressed):
	if !button_pressed:
		checkbutton_audio.text = "OFF"
		AudioServer.set_bus_mute(master_bus,true)
	else:
		checkbutton_audio.text = "ON"
		AudioServer.set_bus_mute(master_bus,false)


func _on_goback_pressed():
	self.hide()
	var calling_menu
	if get_parent():
		if get_parent().find_child("PauseMenu"):
			calling_menu = get_parent().find_child("PauseMenu")
		elif get_parent().find_child("Startmenu"):
			calling_menu = get_parent().find_child("Startmenu")
		if calling_menu:
			calling_menu.show()
		

	
