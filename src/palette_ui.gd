extends PanelContainer
@onready var button_default: TextureButton = $Buttons/DefaultPalette/CenterContainer/Button
@onready var button_1: TextureButton = $Buttons/Palette1/CenterContainer/Button
@onready var button_2: TextureButton = $Buttons/Palette2/CenterContainer/Button

func _ready() -> void:
	button_default.modulate = Refs.default_main_color
	button_1.modulate = Refs.palette_1_main_color
	button_2.modulate = Refs.palette_2_main_color

func _on_button_pressed(arg: int) -> void:
	match arg:
		0:
			Refs.default_palette()
		1:
			Refs.palette_1()
		2:
			Refs.palette_2()
