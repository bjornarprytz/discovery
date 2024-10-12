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
	current_palette_idx = index
	current_palette = _palettes[index]
	palette_changed.emit(current_palette)
