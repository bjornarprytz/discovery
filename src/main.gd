extends Node2D

@onready var score_scene = preload ("res://score.tscn")
@onready var flair = preload ("res://fx/flair.tscn")
@onready var cam: Camera2D = $Camera
@onready var ui: ColorRect = $Camera/CanvasLayer/Border

@onready var score_board: RichTextLabel = $Camera/CanvasLayer/Border/QuestBar/Score
@onready var target_ui: RichTextLabel = $Camera/CanvasLayer/Border/QuestBar/TargetWord
@onready var quest_duration_label: RichTextLabel = $Camera/CanvasLayer/Border/QuestBar/QuestDuration
@onready var quest_bar: ProgressBar = $Camera/CanvasLayer/Border/QuestBar

var target_pos: Vector2
var game_over := false
var show_ui := true
var quest_duration := 0
var tween: Tween

func _ready() -> void:
	cam.position = Corpus.font_size / 2
	target_pos = cam.position
	
	_update_score()
	_on_quest_duration_tick(Game.quest_duration, Game.quest_duration)
	_on_new_target(Game.current_target)
	
	Game.moved.connect(_move)
	Game.quest_duration_tick.connect(_on_quest_duration_tick)
	Game.new_target.connect(_on_new_target)
	Game.invalid_move.connect(_on_invalid_move)
	Game.game_over.connect(_game_over)
	Game.completed_word.connect(_on_completed_word)

func _move(_prev_pos: int, _current_pos: int, direction: Vector2, score_change: int):
	$Camera/Sounds/Click.play()
	target_pos += direction * Corpus.font_size
	if (tween != null):
		tween.kill()
	_update_score()
	tween = create_tween()
	tween.tween_property(cam, 'position', target_pos, .2)
	tween.tween_callback(_flair.bind(score_change))

func _on_invalid_move():
	$Camera/Sounds/Denied.play()

func _on_quest_duration_tick(duration: int, cap: int):
	quest_duration_label.clear()
	quest_duration_label.append_text(str(duration))
	var next_value: float = (float(duration) / float(cap)) * 100.0
	tween = create_tween()
	tween.tween_property(quest_bar, 'value', next_value, .2)

func _on_completed_word(_word: String, was_quest: bool):
	if (was_quest):
		$Camera/Sounds/Quest.play()
	else:
		$Camera/Sounds/CompleteWord.play()

func _on_new_target(word: String):
	target_ui.clear()
	target_ui.append_text("[center]>" + word + "<")

func _update_score():
	score_board.clear()
	score_board.append_text("[right]" + str(Game.score).pad_zeros(5))

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
	tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	tween.tween_property(cam, 'zoom', Vector2.ONE * 10.0, 2.0)
	tween.tween_property($Camera/Fade, 'color', Color.BLACK, 2.0)
	tween.set_parallel(false)
	tween.tween_callback(_show_score)

func _show_score():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(score_scene)

func _toggle_ui():
	show_ui = !show_ui
	
	var toggle_tween = create_tween().set_ease(Tween.EASE_IN)
	if (show_ui):
		toggle_tween.tween_property(ui, 'position:y', 588, .5)
	else:
		toggle_tween.tween_property(ui, 'position:y', 648, .5)

func _unhandled_key_input(event: InputEvent) -> void:
	if (!game_over and event.is_released()):
		var key = event.as_text()
		if (key == "Tab"):
			_toggle_ui()
		else:
			Game.try_move(key)
