extends Node2D

@onready var score_scene = preload ("res://score.tscn")
@onready var flair = preload ("res://fx/flair.tscn")
@onready var cam: Camera2D = $Camera
@onready var ui: DiscoveryUI = $Camera/CanvasLayer

var camera_tween: Tween

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

func _move(_prev_pos: int, _current_pos: int, direction: Vector2, score_change: int):
	$Camera/Sounds/Click.play()
	target_pos += direction * Corpus.font_size
	if (camera_tween != null):
		camera_tween.kill()
	ui.update_score()
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

func _game_over():
	$Camera/Sounds/Finished.play()
	game_over = true
	Engine.time_scale = 0.4
	camera_tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	camera_tween.tween_property(cam, 'zoom', Vector2.ONE * 10.0, 2.0)
	camera_tween.tween_property($Camera/Fade, 'color', Color.BLACK, 2.0)
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
			Game.try_move(key)
