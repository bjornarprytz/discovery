class_name AudioController
extends Node

@onready var main: AudioStreamPlayer = $Main
@onready var main2: AudioStreamPlayer = $Main2

@onready var score_track = preload("res://assets/Bookworm - MichaelBackson - 16.06.2024, 22.59.wav")
@onready var intro_track = preload("res://assets/Bookworm - morningistheend - 16.06.2024, 23.09.wav")

@onready var klokke_track = preload("res://assets/MichaelBackson - klokke.wav")
@onready var mye_track = preload("res://assets/MichaelBackson - mye.wav")
@onready var secret_track = preload("res://assets/MichaelBackson - secret.wav")
@onready var stats_track = preload("res://assets/MichaelBackson - stats.wav")


@onready var players: Array[AudioStreamPlayer] = [main, main2]

var _current_player_index = 0
var main_player: AudioStreamPlayer:
	get:
		return players[_current_player_index]
var secondary_player: AudioStreamPlayer:
	get:
		return players[(_current_player_index + 1) % players.size()]


func _ready():
	for player in players:
		player.finished.connect(player.play)

func _rotate_main_player():
	_current_player_index = (_current_player_index + 1) % players.size()

func fade_out():
	var playerToFade = main_player
	
	var tween = create_tween()
	tween.tween_property(playerToFade, "volume_db", -80, 1.0)
	await tween.finished
	playerToFade.stop()
	
	_rotate_main_player()

func fade_in(new_stream: AudioStream):
	main_player.stream = new_stream
	main_player.play()
	var tween = create_tween()
	tween.tween_property(main_player, "volume_db", 0.0, 1.0)

func cross_fade(new_stream: AudioStream):
	
	var current_playback_position = 0.0 if main_player == null else main_player.get_playback_position()
	if new_stream.get_length() < current_playback_position:
		current_playback_position = 0.0

	secondary_player.stream = new_stream
	secondary_player.play(current_playback_position) # Sync playback position
	var tween = create_tween().set_parallel()
	tween.tween_property(main_player, "volume_db", -80, 1.0) # Fade out
	tween.tween_property(secondary_player, "volume_db", 0.0, 1.0) # Fade in
	tween.set_parallel(false)
	tween.tween_callback(main_player.stop)
	await tween.finished
	_rotate_main_player()
