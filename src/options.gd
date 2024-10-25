extends Node2D
@export var transition_speed: float = 0.2

@onready var score_scene = preload("res://score.tscn")

@onready var next_button: Button = $CanvasLayer/NextButton
@onready var prev_button: Button = $CanvasLayer/PrevButton

@onready var menus: Array[Node] = $CanvasLayer/Background.get_children()

var current_menu_index := 0

var current_menu: Node:
	get:
		return menus[current_menu_index]

var prev_menu: Node:
	get:
		return menus[(current_menu_index - 1) % menus.size()]

var next_menu: Node:
	get:
		return menus[(current_menu_index + 1) % menus.size()]

func _ready() -> void:
	assert(menus.size() > 0, "No menus found.")

	current_menu.show()

	if menus.size() == 1:
		next_button.hide()
		prev_button.hide()
	else:
		_update_button_text()
	
	Audio.cross_fade(Audio.secret_track)

func _on_next_button_pressed() -> void:
	next_menu.position.x = next_menu.size.x
	next_menu.show()

	var tween = create_tween().set_parallel()
	tween.tween_property(next_menu, "position:x", 0, transition_speed)
	tween.tween_property(current_menu, "position:x", -current_menu.size.x, transition_speed)

	await tween.finished

	current_menu.hide()
	current_menu_index = (current_menu_index + 1) % menus.size()

	_update_button_text()

func _on_prev_button_pressed() -> void:
	prev_menu.position.x = -prev_menu.size.x
	prev_menu.show()

	var tween = create_tween().set_parallel()
	tween.tween_property(prev_menu, "position:x", 0, transition_speed)
	tween.tween_property(current_menu, "position:x", current_menu.size.x, transition_speed)

	await tween.finished
	
	current_menu.hide()
	current_menu_index = (current_menu_index - 1) % menus.size()

	_update_button_text()

func _update_button_text():
	next_button.text = next_menu.name + ">"
	prev_button.text = "<" + prev_menu.name

func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(score_scene)
