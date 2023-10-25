extends Node2D

@onready var score_scene = preload("res://score.tscn")
@onready var flair = preload("res://fx/flair.tscn")
@onready var cam : Camera2D = $Camera
@onready var game : TextGame = $Text
@onready var ui : ColorRect = $Camera/CanvasLayer/Border

@onready var score_board : RichTextLabel = $Camera/CanvasLayer/Border/ColorRect/Score
@onready var target_ui : RichTextLabel = $Camera/CanvasLayer/Border/ColorRect/TargetWord

var target_pos : Vector2
var game_over := false
var show_ui := true

func _ready() -> void:
	Global.score = 0
	cam.position = Global.font_size / 2
	target_pos = cam.position
	_new_target(Global.current_target)
	_update_score()
	cam.zoom = Vector2(.5, .5)
	Global.moved.connect(_move)
	Global.new_target.connect(_new_target)
	Global.game_over.connect(_game_over)
	Global.completed_quest.connect($Sounds/Quest.play)

var tween : Tween

func _move(step: Vector2, score_change: int):
	$Sounds/Click.play()
	target_pos += step
	Global.score += score_change
	if (tween != null):
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(cam, 'position', target_pos, .2)
	tween.tween_callback(_flair.bind(score_change))

func _new_target(word : String):
	target_ui.clear()
	target_ui.append_text("[center]>"+word+"<")

func _update_score():
	score_board.clear()
	score_board.append_text("[right]"+str(Global.score).pad_zeros(5))

func _flair(amount: int):
	var f = flair.instantiate() as CPUParticles2D
	add_child(f)
	f.position = cam.position
	f.amount = amount
	f.emitting = true
	await get_tree().create_timer(f.lifetime).timeout
	_update_score()
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
