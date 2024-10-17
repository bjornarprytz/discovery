extends Node

signal palette_changed(palette: Palette)

@export var palettes: Array[Palette]

var current_palette_idx: int = 0
var current_palette: Palette:
	get:
		if current_palette_idx >= palettes.size():
			return null
		return palettes[current_palette_idx]

func set_palette(index: int) -> void:
	if index < 0 or index >= palettes.size():
		set_palette(0)
		return
	
	var prev_palette = current_palette
	current_palette_idx = index
	if prev_palette != current_palette:
		palette_changed.emit(current_palette)

func _ready() -> void:
	set_palette(PlayerData.player_data.color_palette)
