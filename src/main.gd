extends Node2D

@onready var cam : Camera2D = $Camera
@onready var game : TextGame = $Text


var target_pos : Vector2

func _ready() -> void:
	cam.position = Global.font_size / 2
	target_pos = cam.position
	cam.zoom = Vector2(.6, .6)
	Global.moved.connect(_move_target)
	Global.game_over.connect(_game_over)

var tween : Tween

func _move_target(step: Vector2):
	target_pos += step
	if (tween != null):
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(cam, 'position', target_pos, .2)

func _game_over():
	tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	tween.tween_property(cam, 'zoom', Vector2.ONE * 10.0, 2.0)
	tween.tween_property($Camera/CameraFade, 'color', Color.BLACK, 2.0)
	tween.set_parallel(false)
	tween.tween_callback(_show_score)
	tween.tween_property($Camera/CanvasLayer/GameOver, 'modulate', Color.WHITE, 2.0)

func _show_score():
	$Camera/CanvasLayer/GameOver.visible = true
	$Camera/CanvasLayer/GameOver.modulate = Color.BLACK

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		var key = event.as_text()
		game.try_move(key)
