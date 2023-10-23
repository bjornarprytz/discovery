extends Node2D

@onready var cam : Camera2D = $Camera
@onready var text : Node2D = $Text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam.position = text.center
	cam.zoom = Vector2(0.1, 0.05) # For testing infinite scroll


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
