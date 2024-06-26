class_name SplashScreen
extends CanvasLayer

@onready var timer: Timer = $Timer

func _ready() -> void:
	Audio.play_score()

func _on_timer_timeout() -> void:
	_fade_out()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		_fade_out()

func _fade_out():
	var tween = create_tween()
	tween.tween_property($Control, "modulate", Color.from_string("060637", Color.BLACK), .69)

	await tween.finished

	get_tree().change_scene_to_file("res://main.tscn")
