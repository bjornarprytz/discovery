class_name SplashScreen
extends CanvasLayer

@onready var title: TextureRect = $Control/Title

func _ready() -> void:
	Audio.fade_in(Audio.klokke_track)
	title.visible = true
	title.modulate.a = 0.0
	var tween = create_tween().set_ease(Tween.EASE_IN) # .set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(title, "modulate:a", 1.0, .69)
	

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		_fade_out()

func _fade_out():
	var tween = create_tween()
	tween.tween_property($Control, "modulate", Color.from_string("060637", Color.BLACK), .69)

	await tween.finished

	get_tree().change_scene_to_file("res://main.tscn")
