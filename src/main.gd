extends Node2D

@onready var score_scene = preload("res://score.tscn")
@onready var cam : Camera2D = $Camera
@onready var game : TextGame = $Text

var target_pos : Vector2
var game_over := false

func _ready() -> void:
	Global.score = 0
	cam.position = Global.font_size / 2
	target_pos = cam.position
	cam.zoom = Vector2(.6, .6)
	Global.moved.connect(_move)
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

func _unhandled_key_input(event: InputEvent) -> void:
	if (!game_over and event.is_released()):
		var key = event.as_text()
		if (!game.try_move(key)):
			$Sounds/Denied.play()
