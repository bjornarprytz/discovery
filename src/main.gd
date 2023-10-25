extends Node2D

@onready var score_scene = preload("res://score.tscn")
@onready var flair = preload("res://fx/flair.tscn")
@onready var cam : Camera2D = $Camera
@onready var game : TextGame = $Text
@onready var ui : ColorRect = $Camera/CanvasLayer/Border

@onready var score_board : RichTextLabel = $Camera/CanvasLayer/Border/FatigueBar/Score
@onready var target_ui : RichTextLabel = $Camera/CanvasLayer/Border/FatigueBar/TargetWord
@onready var steps_to_fatigue : RichTextLabel = $Camera/CanvasLayer/Border/FatigueBar/StepsToFatigue
@onready var fatigue_bar : ProgressBar = $Camera/CanvasLayer/Border/FatigueBar

var target_pos : Vector2
var game_over := false
var show_ui := true
var word_fatigue := 0

func _ready() -> void:
	Game.score = 0
	cam.position = Corpus.font_size / 2
	target_pos = cam.position
	_new_target(Game.current_target)
	_update_score()
	cam.zoom = Vector2(.5, .5)
	Game.moved.connect(_move)
	Game.new_target.connect(_new_target)
	Game.game_over.connect(_game_over)
	Game.completed_quest.connect($Sounds/Quest.play)

var tween : Tween

func _move(step: Vector2, score_change: int):
	$Sounds/Click.play()
	target_pos += step
	Game.score += score_change
	if (tween != null):
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(cam, 'position', target_pos, .2)
	tween.tween_callback(_flair.bind(score_change))
	_tick_fatigue()

func _reset_fatigue():
	word_fatigue = Game.current_target.length() * Game.FATIGUE_FACTOR
	steps_to_fatigue.clear()
	steps_to_fatigue.append_text(str(word_fatigue))
	tween = create_tween()
	tween.tween_property(fatigue_bar, 'value', 100.0, .2)

func _tick_fatigue():
	word_fatigue -= 1
	steps_to_fatigue.clear()
	steps_to_fatigue.append_text(str(word_fatigue))
	var next_value: float = (float(word_fatigue) / float(Game.current_target.length() * Game.FATIGUE_FACTOR)) * 100.0
	tween = create_tween()
	tween.tween_property(fatigue_bar, 'value', next_value, .2)
	if (word_fatigue <= 0):
		Game.cycle_target()

func _new_target(word : String):
	target_ui.clear()
	target_ui.append_text("[center]>"+word+"<")
	_reset_fatigue()

func _update_score():
	score_board.clear()
	score_board.append_text("[right]"+str(Game.score).pad_zeros(5))

func _flair(amount: int):
	var f = flair.instantiate() as CPUParticles2D
	add_child(f)
	f.position = cam.position
	f.amount = amount
	f.emitting = true
	_update_score()
	await get_tree().create_timer(f.lifetime).timeout
	f.queue_free()

func _game_over():
	$Sounds/Finished.play()
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
	
	tween = create_tween().set_ease(Tween.EASE_IN)
	if (show_ui):
		tween.tween_property(ui, 'position:y', 588, .5)
	else:
		tween.tween_property(ui, 'position:y', 648, .5)

func _unhandled_key_input(event: InputEvent) -> void:
	if (!game_over and event.is_released()):
		var key = event.as_text()
		if (key == "Tab"):
			_toggle_ui()
		elif (!game.try_move(key)):
			$Sounds/Denied.play()
