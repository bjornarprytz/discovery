extends Node2D

@onready var score_scene = preload("res://score.tscn")
@onready var flair = preload("res://fx/flair.tscn")
@onready var tutorial_spawner = preload("res://tutorial.tscn")
@onready var cam: Camera2D = $Camera
@onready var ui: DiscoveryUI = $Camera/CanvasLayer
@onready var game_over_label: RichTextLabel = $Camera/CanvasLayer/GameOver
@onready var skip_label: RichTextLabel = $Camera/CanvasLayer/SkipText

@onready var text_game: TextGame = $Text

const TUTORIAL_TIMER = 6.9

var camera_tween: Tween
var tutorial: TutorialUI

var _current_chapter: CorpusClass.Chapter
var made_first_move: bool
var target_pos: Vector2
var game_over := false
var show_menu := false
var quest_duration := 0

func _ready() -> void:
	cam.position = Corpus.font_size / 2
	target_pos = cam.position
	
	Game.moved.connect(_move)
	Game.invalid_move.connect(_on_invalid_move)
	Game.game_over.connect(_game_over)
	Game.completed_word.connect(_on_completed_word)
	
	get_tree().create_timer(TUTORIAL_TIMER).timeout.connect(_show_tutorial, CONNECT_ONE_SHOT)

	Game.force_move(text_game._segments[1][1].start_index, true)
	Game.ready_to_move.emit()
	Game.new_corpus.emit(Corpus.main_corpus)

	_fade_in()

func _fade_in():
	var tween = create_tween()
	text_game.modulate.a = 0.0
	tween.tween_property(text_game, 'modulate:a', 1.0, 1.69)

	await Audio.play_main()

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
	text_game.queue_full_refresh()
	tutorial.stop()

func _move(_prev_pos: int, current_pos: int, direction: Vector2, score_change: int):
	$Camera/Sounds/Click.play()
	target_pos += direction * Corpus.font_size
	if (camera_tween != null):
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.tween_property(cam, 'position', target_pos, .2)
	camera_tween.tween_callback(_flair.bind(score_change))

	var next_chapter = Corpus.get_chapter_at(current_pos)

	if (_current_chapter != next_chapter):
		_current_chapter = next_chapter
		Game.new_chapter.emit(_current_chapter)

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

func _game_over(_stats: Data.Stats):
	$Camera/Sounds/Finished.play()
	game_over = true
	game_over_label.show()
	game_over_label.modulate.a = 0.0
	Engine.time_scale = 0.5
	camera_tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	camera_tween.tween_property(cam, 'zoom', Vector2.ONE * 10.0, 1.8)
	camera_tween.tween_property($Camera/Fade, 'color', Color.BLACK, 1.8)
	camera_tween.tween_property(game_over_label, 'modulate:a', 1.0, 1.8)
	camera_tween.tween_interval(3.0)
	camera_tween.set_parallel(false)
	camera_tween.tween_callback(_show_score)

func _show_score():
	game_over = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(score_scene)

func _toggle_menu():
	show_menu = !show_menu
	ui.set_show_menu(show_menu)

func _unhandled_key_input(event: InputEvent) -> void:
	if (!game_over and event.is_released()):
		var key = event.as_text()
		if (key == "Tab" or key == "Escape"):
			_toggle_menu()
		elif !show_menu:
			if Game.try_move(key):
				made_first_move = true
				_hide_tutorial()
			Game.ready_to_move.emit()
	elif game_over and event.is_pressed():
		if event.as_text() == "Space":
			Engine.time_scale = 2.0
		else:
			_show_skip()

func _show_skip():
	skip_label.modulate.a = 0.0
	skip_label.show()

	var tween = create_tween()
	tween.tween_property(skip_label, "modulate:a", 1.0, .2)
