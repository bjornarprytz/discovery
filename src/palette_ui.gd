extends PanelContainer

@onready var button_default: TextureButton = %ButtonDefault
@onready var button_peter_pan: TextureButton = %ButtonPeterPan
@onready var button_robinson_crusoe: TextureButton = %ButtonRobinsonCrusoe
@onready var button_oz: TextureButton = %ButtonOz

func _ready() -> void:
	button_default.modulate = Palette.alice().mark_color
	button_peter_pan.modulate = Palette.peter().mark_color
	button_robinson_crusoe.modulate = Palette.robinson().mark_color
	button_oz.modulate = Palette.oz().mark_color

func _on_button_pressed(arg: int) -> void:
	Refs.set_palette(arg)
