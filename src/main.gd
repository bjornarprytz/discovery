extends Node2D

@onready var cam : Camera2D = $Camera
@onready var game : TextGame = $Text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam.position = game.center
	cam.zoom = Vector2(0.1, 0.05) # For testing infinite scroll


func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		var key = event.as_text()
		print(key)
		if (game.try_move(key)):
			print("Moved to ", key)
