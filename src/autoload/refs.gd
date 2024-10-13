extends Node

signal palette_changed(palette: Palette)

var _palettes: Array[Palette] = [
	Palette.alice(),
	Palette.peter(),
	Palette.robinson(),
	Palette.oz()
]

var current_palette_idx: int = 0
@export var current_palette: Palette = _palettes[current_palette_idx]

func set_palette(index: int) -> void:
	if index < 0 or index >= _palettes.size():
		set_palette(0)
		return
	current_palette_idx = index
	current_palette = _palettes[index]
	palette_changed.emit(current_palette)

func _ready() -> void:
	set_palette(PlayerData.player_data.color_palette)
