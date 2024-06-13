extends Node2D

@onready var score_scene = preload ("res://score.tscn")
@onready var flair = preload ("res://fx/flair.tscn")
@onready var tutorial_spawner = preload ("res://tutorial.tscn")
@onready var cam: Camera2D = $Camera
@onready var ui: DiscoveryUI = $Camera/CanvasLayer
@onready var game_over_label: RichTextLabel = $Camera/CanvasLayer/GameOver

@onready var text_game: TextGame = $Text

var camera_tween: Tween
var tutorial: TutorialUI

var made_first_move: bool
var target_pos: Vector2
var game_over := false
var show_ui := true
var quest_duration := 0

func _ready() -> void:
	cam.position = Corpus.font_size / 2
	target_pos = cam.position
	
	Game.moved.connect(_move)
	Game.invalid_move.connect(_on_invalid_move)
	Game.game_over.connect(_game_over)
	Game.completed_word.connect(_on_completed_word)
	
	get_tree().create_timer(10.0).timeout.connect(_show_tutorial, CONNECT_ONE_SHOT)

	Game.force_move(text_game.center_segment.start_index, true)

func _show_tutorial():
	if (made_first_move):
		return
		
	if tutorial != null:
		tutorial.queue_free()
	
	tutorial = tutorial_spawner.instantiate() as TutorialUI
	ui.add_child(tutorial)
	tutorial.modulate.a = 0.0
	text_game.force_refresh()
	
	var tween = create_tween()
	tween.tween_property(tutorial, "modulate:a", 1.0, .69)
	
func _hide_tutorial():
	if (tutorial == null or tutorial.is_queued_for_deletion()):
		return
	var tween = create_tween()
	tween.tween_property(tutorial, "modulate:a", 0.0, .69)
	
	await tween.finished

	if tutorial != null and !tutorial.is_queued_for_deletion():
		tutorial.stop()
	text_game.force_refresh()

func _move(_prev_pos: int, _current_pos: int, direction: Vector2, score_change: int):
	$Camera/Sounds/Click.play()
	target_pos += direction * Corpus.font_size
	if (camera_tween != null):
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.tween_property(cam, 'position', target_pos, .2)
	camera_tween.tween_callback(_flair.bind(score_change))

func _on_invalid_move():
	$Camera/Sounds/Denied.play()

func _on_completed_word(_word: String, was_quest: bool):
	if (was_quest):
		$Camera/Sounds/Quest.play()
	else:
		$Camera/Sounds/CompleteWord.play()

func _flair(amount: int):
	var f = flair.instantiate() as CPUParticles2D
	add_child(f)
	f.position = cam.position
	f.amount = amount
	f.emitting = true
	await get_tree().create_timer(f.lifetime).timeout
	f.queue_free()

func _game_over(_score: int):
	$Camera/Sounds/Finished.play()
	game_over = true
	game_over_label.show()
	game_over_label.modulate = Color(1, 1, 1, 0)
	Engine.time_scale = 0.5
	camera_tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	camera_tween.tween_property(cam, 'zoom', Vector2.ONE * 10.0, 1.8)
	camera_tween.tween_property($Camera/Fade, 'color', Color.BLACK, 1.8)
	camera_tween.tween_property(game_over_label, 'modulate:a', 1.0, 1.8)
	camera_tween.tween_interval(3.0)
	camera_tween.set_parallel(false)
	camera_tween.tween_callback(_show_score)

func _show_score():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(score_scene)

func _toggle_ui():
	show_ui = !show_ui
	ui.set_show(show_ui)

func _unhandled_key_input(event: InputEvent) -> void:
	if (!game_over and event.is_released()):
		var key = event.as_text()
		if (key == "Tab"):
			_toggle_ui()
		else:
			if Game.try_move(key):
				made_first_move = true
				_hide_tutorial()
