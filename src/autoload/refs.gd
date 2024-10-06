extends Node

signal palette_changed()

@export var background_color: Color = Color.from_string("060637", Color.PURPLE)
@export var text_color: Color = Color.WHITE
@export var quest_color: Color = Color.GOLDENROD
@export var error_color: Color = Color.CRIMSON
@export var mark_color: Color = Color.AQUAMARINE
@export var inert_color: Color = Color.DIM_GRAY


func set_palette(bg: Color = Color.from_string("060637", Color.PURPLE), txt: Color = Color.WHITE, qst: Color = Color.GOLDENROD, err: Color = Color.CRIMSON, mrk: Color = Color.AQUAMARINE, inr: Color = Color.DIM_GRAY) -> void:
	background_color = bg
	text_color = txt
	quest_color = qst
	error_color = err
	mark_color = mrk
	inert_color = inr
	
	palette_changed.emit()

var flip_flop: bool = false
func _input(event: InputEvent) -> void:
	# Toggle palette with F1
	if event.is_action_pressed("debug_signal"):
		flip_flop = !flip_flop
		if flip_flop:
			set_palette(Color.from_string("060637", Color.PURPLE), Color.WHITE, Color.GOLDENROD, Color.CRIMSON, Color.AQUAMARINE, Color.DIM_GRAY)
		else:
			set_palette(Color.PINK, Color.BLACK, Color.BEIGE, Color.GREEN, Color.RED, Color.YELLOW)
