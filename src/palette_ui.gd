extends PanelContainer

@export var button_theme: Theme
@export var palette_button_icon: Texture
@export var current_palette_button_icon: Texture

@onready var buttons: HBoxContainer = %Buttons

func _ready() -> void:
	Refs.palette_changed.connect(_on_palette_changed)

	var i = 0
	for palette in Refs.palettes:
		var button = Button.new()
		
		if i == Refs.current_palette_idx:
			button.icon = current_palette_button_icon
		else:
			button.icon = palette_button_icon
			
		button.theme = button_theme
		button.modulate = palette.mark_color
		button.pressed.connect(_on_button_pressed.bind(i))
		buttons.add_child(button)
		i += 1
	

func _on_palette_changed(_palette: Palette) -> void:
	for button in buttons.get_children():
		if button.get_index() == Refs.current_palette_idx:
			button.icon = current_palette_button_icon
		else:
			button.icon = palette_button_icon

func _on_button_pressed(arg: int) -> void:
	Refs.set_palette(arg)
