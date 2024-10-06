extends Node

signal palette_changed()

@export var background_color: Color = Color.from_string("060637", Color.PURPLE)
@export var tutorial_color: Color = Color.from_string("007c5f", Color.SEA_GREEN)
@export var text_color: Color = Color.WHITE
@export var text_contrast_color: Color = Color.BLACK
@export var quest_color: Color = Color.GOLDENROD
@export var error_color: Color = Color.CRIMSON
@export var mark_color: Color = Color.AQUAMARINE
@export var inert_color: Color = Color.DIM_GRAY


var default_main_color = Color.GOLDENROD
func default_palette() -> void:
	set_palette()

var palette_1_main_color: Color = Color.from_string("0b6a26", Color.WEB_PURPLE) # Peter pan green
func palette_1() -> void:
	set_palette(
		Color.from_string("33223D", Color.WEB_PURPLE), # Dark purple
		Color.from_string("5FE193", Color.WEB_PURPLE), # Light green
		Color.from_string("f6f5ae", Color.WEB_PURPLE), # Light yellow
		Color.from_string("0b6a26", Color.WEB_PURPLE), # Peter pan green
		Color.from_string("f2013c", Color.WEB_PURPLE), # Red
		Color.from_string("50BAFC", Color.WEB_PURPLE), # Blue
		Color.from_string("565554", Color.WEB_PURPLE), # Gray
		)

var palette_2_main_color = Color.from_string("1B768A", Color.SEA_GREEN) # Robinson Crusoe Teal
func palette_2() -> void:
	set_palette(
		Color.from_string("3E3019", Color.PURPLE), # Brown
		Color.from_string("007c5f", Color.SEA_GREEN), # Teal
		Color.from_string("7182F0", Color.SEA_GREEN), # Indigo
		Color.from_string("1B768A", Color.SEA_GREEN), # Robinson Crusoe Teal
		Color.from_string("b33001", Color.SEA_GREEN), # Rust
		Color.from_string("b06d08", Color.SEA_GREEN), # Orange
		Color.from_string("565554", Color.SEA_GREEN), # Gray
		)

func set_palette(
	bg: Color = Color.from_string("060637", Color.PURPLE),
	tut: Color = Color.from_string("007c5f", Color.SEA_GREEN),
	txt: Color = Color.WHITE,
	qst: Color = Color.GOLDENROD,
	err: Color = Color.CRIMSON,
	mrk: Color = Color.AQUAMARINE,
	inr: Color = Color.DIM_GRAY
	) -> void:
	background_color = bg
	tutorial_color = tut
	text_color = txt
	text_contrast_color = Utils.get_contrast_color(txt)
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
			set_palette(Color.from_string("060637", Color.PURPLE), Color.from_string("007c5f", Color.SEA_GREEN), Color.WHITE, Color.GOLDENROD, Color.CRIMSON, Color.AQUAMARINE, Color.DIM_GRAY)
		else:
			set_palette(Color.PINK, Color.YELLOW, Color.BLACK, Color.BEIGE, Color.GREEN, Color.RED, Color.YELLOW)
