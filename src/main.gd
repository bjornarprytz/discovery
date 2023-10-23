extends Node2D

@onready var cam : Camera2D = $Camera
@onready var game : TextGame = $Text


var target_pos : Vector2

func _ready() -> void:
	cam.position = Autoload.font_size / 2
	target_pos = cam.position
	cam.zoom = Vector2(.6, .6)
	Autoload.moved.connect(_move_target)

var tween : Tween

func _move_target(step: Vector2):
	target_pos += step
	if (tween != null):
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(cam, 'position', target_pos, .2)
		

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		var key = event.as_text()
		if (game.try_move(key)):
			print("Moved to ", key)
