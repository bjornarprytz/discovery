class_name AudioController
extends AudioStreamPlayer

@onready var score_track = preload ("res://assets/Bookworm - MichaelBackson - 16.06.2024, 22.59.wav")
@onready var intro_track = preload ("res://assets/Bookworm - morningistheend - 16.06.2024, 23.09.wav")

func _ready():
	finished.connect(play)

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 1.0)
	await tween.finished
	stop()

func fade_in():
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", 0.0, 1.0)

func play_main():
	await fade_out()
	stream = null

func play_score():
	if stream == score_track:
		return
	stream = score_track
	await fade_in()
