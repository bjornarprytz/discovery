class_name Palette
extends Resource

@export var background_color: Color = Color.from_string("060637", Color.PURPLE)
@export var background_accent_color: Color = Color.from_string("1c1c86", Color.PURPLE)
@export var tutorial_color: Color = Color.from_string("007c5f", Color.SEA_GREEN)
@export var text_color: Color = Color.WHITE
@export var text_contrast_color: Color = Color.BLACK
@export var quest_color: Color = Color.GOLDENROD
@export var error_color: Color = Color.CRIMSON
@export var mark_color: Color = Color.AQUAMARINE
@export var inert_color: Color = Color.DIM_GRAY


static func alice() -> Palette:
	var palette = Palette.new()
	palette.background_color = Color.from_string("060637", Color.PURPLE)
	palette.background_accent_color = Color.from_string("1c1c86", Color.PURPLE)
	palette.tutorial_color = Color.from_string("007c5f", Color.SEA_GREEN)
	palette.text_color = Color.WHITE
	palette.text_contrast_color = Utils.get_contrast_color(palette.text_color)
	palette.quest_color = Color.GOLDENROD
	palette.error_color = Color.CRIMSON
	palette.mark_color = Color.AQUAMARINE
	palette.inert_color = Color.DIM_GRAY
	return palette

static func peter() -> Palette:
	var palette = Palette.new()
	palette.background_color = Color.from_string("33223D", Color.WEB_PURPLE)
	palette.background_accent_color = Color.from_string("8E3DBD", Color.WEB_PURPLE)
	palette.tutorial_color = Color.from_string("5FE193", Color.WEB_PURPLE)
	palette.text_color = Color.from_string("f6f5ae", Color.WEB_PURPLE)
	palette.text_contrast_color = Utils.get_contrast_color(palette.text_color)
	palette.quest_color = Color.from_string("0b6a26", Color.WEB_PURPLE)
	palette.error_color = Color.from_string("f2013c", Color.WEB_PURPLE)
	palette.mark_color = Color.from_string("50BAFC", Color.WEB_PURPLE)
	palette.inert_color = Color.from_string("565554", Color.WEB_PURPLE)

	return palette

static func robinson() -> Palette:
	var palette = Palette.new()
	palette.background_color = Color.from_string("3E3019", Color.PURPLE)
	palette.background_accent_color = Color.from_string("604C2A", Color.PURPLE)
	palette.tutorial_color = Color.from_string("007c5f", Color.SEA_GREEN)
	palette.text_color = Color.from_string("7182F0", Color.SEA_GREEN)
	palette.text_contrast_color = Utils.get_contrast_color(palette.text_color)
	palette.quest_color = Color.from_string("1B768A", Color.SEA_GREEN)
	palette.error_color = Color.from_string("b33001", Color.SEA_GREEN)
	palette.mark_color = Color.from_string("b06d08", Color.SEA_GREEN)
	palette.inert_color = Color.from_string("565554", Color.SEA_GREEN)

	return palette


static func oz() -> Palette:
	var palette = Palette.new()
	palette.background_color = Color.from_string("4ea6f1", Color.PURPLE)
	palette.background_accent_color = Color.from_string("1391FF", Color.PURPLE)
	palette.tutorial_color = Color.from_string("7182F0", Color.SEA_GREEN)
	palette.text_color = Color.WHITE
	palette.text_contrast_color = Utils.get_contrast_color(palette.text_color)
	palette.quest_color = Color.from_string("156E23", Color.PURPLE)
	palette.error_color = Color.from_string("0b0706", Color.PURPLE)
	palette.mark_color = Color.from_string("fee624", Color.PURPLE)
	palette.inert_color = Color.from_string("A5A3A0", Color.SEA_GREEN)

	return palette
