extends Node

@export var music: AudioStreamPlayer
@export var voice: AudioStreamPlayer

var fading : bool = false


var cross_fade_player: AudioStreamPlayer

@export var sfx_player: AudioStreamPlayer

var sfx_player_arr: Array[AudioStreamPlayer]

var audio_path = "res://assets/soundscape/music/"
var sfx_path = "res://assets/soundscape/sfx/"

func _ready():
	SignalManager.play_audio.connect(_on_play_audio)
	SignalManager.change_audio.connect(_on_audio_change_request)
	SignalManager.kill_sfx.connect(_on_kill_sfx)
	SignalManager.change_audio_with_loop.connect(_on_audio_change_request)
	#SignalManager.stop_audio.connect()
	#SignalManager.play_audio_collection.connect(_on_play_audio_collection)

func _process(delta):
	if fading && cross_fade_player:
		music.volume_db -= 15*delta
#		print(music.volume_db)
		if music.volume_db <= -30:
			music.volume_db = -30
			cross_fade_player.volume_db += 15 * delta
#			print(cross_fade_player.volume_db)
		if cross_fade_player.volume_db > -30:
			cross_fade_player.volume_db = -30
#			print(cross_fade_player.volume_db)
			change_music_player_to_original()
			fading = false
			delete_cross_fade_player()
#	SFX volume fade
#	for every_sfx_player in sfx_player_arr:
#		if every_sfx_player.volume_db <= 0:
#			every_sfx_player.volume_db += 30 * delta
#		print(every_sfx_player.volume_db)


func create_cross_fade_player(music_type: String) -> void:
	if !cross_fade_player:
		cross_fade_player = AudioStreamPlayer.new()
		add_child(cross_fade_player)
		cross_fade_player.bus = "music"
		cross_fade_player.volume_db = -60
		cross_fade_player.stream = load(music_type)
		cross_fade_player.stream.loop = true
		cross_fade_player.play()
		
		
	
func delete_cross_fade_player() -> void:
	cross_fade_player.queue_free()
	cross_fade_player = null

func change_music_player_to_original()-> void:
	music.stream = cross_fade_player.stream
	music.play(cross_fade_player.get_playback_position())
	

func _on_audio_change_request(filename: String, audioplayer: String, loop:bool=false):
	match [audioplayer]:
		["MUSIC"]:
			var music_track = "%s%s.mp3" % [audio_path, filename]
			create_cross_fade_player(music_track)
			fading = true
			#play_music("%s%s.mp3" % [audio_path, filename])
		["SFX"]:
			var sfx_track = "%s%s.wav" % [sfx_path, filename]
			play_sfx(sfx_track, loop)
			pass
		["VOICE"]:
			#play_voice(filename)
			pass

func _on_play_audio(filename: String, _audioplayer: String):
	var music_track = "%s%s.mp3" % [audio_path, filename]
	music.stream= load(music_track)
	music.stream.loop= true
	#music.volume_db= -30
	music.play()

#func play_music(music_type):
#	if music:
##		#fade ou
##		music.stream = load(music_type)
##		music.play()
#		fading = truea
##		#fade in

func play_sfx(sfx_track: String, loop: bool = false):
#	print(sfx_track)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "sfx"
	add_child(sfx_player)
	sfx_player.stream = load(sfx_track)
	if !loop:
		sfx_player.finished.connect(_on_sfx_finished)
#	else:
	#wave sounds zu loopen ist eine katastophe :( wenn man das neu importiert klappt es
#		sfx_player.stream.loop_mode = 2
#		sfx_player.stream.loop_begin = 0
#		sfx_player.stream.loop_end = -1
		
	sfx_player.play()
	sfx_player_arr.append(sfx_player)
		

	

func _on_sfx_finished()->void:
	for every_sfx_player in sfx_player_arr:
		if !every_sfx_player.playing:
			remove_child(every_sfx_player)
			sfx_player_arr.erase(every_sfx_player)
			every_sfx_player.queue_free()
	#sfx_player=null
	
func _on_kill_sfx(filename:String)->void:
	var file = "%s%s.wav" % [sfx_path,filename]
	var file_player = AudioStreamPlayer.new()
	file_player.stream = load(file)
	for find_sfx_player in sfx_player_arr:
		if find_sfx_player.stream is AudioStreamWAV and file_player.stream is AudioStreamWAV and find_sfx_player.stream.data == file_player.stream.data:
			remove_child(find_sfx_player)
			sfx_player_arr.erase(find_sfx_player)
			find_sfx_player.queue_free()
	file_player.queue_free()
			
#func _on_play_audio_collection(sound_files:Array)->void:
#	var index = randi_range(0,sound_files.size()-1)
#	var track_name = ("%s%s.wav" % [sfx_path,sound_files[index]])
#	play_sfx(track_name)
#
func play_voice(_music_type):
	if voice:
		pass
