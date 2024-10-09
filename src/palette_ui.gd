extends PanelContainer

@onready var button_default: TextureButton = %ButtonDefault
@onready var button_peter_pan: TextureButton = %ButtonPeterPan
@onready var button_robinson_crusoe: TextureButton = %ButtonRobinsonCrusoe
@onready var button_oz: TextureButton = %ButtonOz

func _ready() -> void:
	button_default.modulate = Refs.default_main_color
	button_peter_pan.modulate = Refs.palette_1_main_color
	button_robinson_crusoe.modulate = Refs.palette_2_main_color
	button_oz.modulate = Refs.palette_oz_main_color

func _on_button_pressed(arg: int) -> void:
	match arg:
		0:
			Refs.default_palette()
		1:
			Refs.palette_peter_pan()
		2:
			Refs.palette_robinson()
		3:
			Refs.palette_oz()
