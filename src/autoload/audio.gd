class_name AudioController
extends AudioStreamPlayer

@onready var main_track = preload("res://assets/Bookworm - MichaelBackson - 16.06.2024, 22.59.wav")
@onready var score_track = preload("res://assets/Bookworm - morningistheend - 16.06.2024, 23.09.wav")

func play_main():
	stream = main_track
	play()

func play_score():
	stream = score_track
	play()
