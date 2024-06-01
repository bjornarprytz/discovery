class_name Highlight
extends RichTextEffect

# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [hightlight param=2.0]hello[/hightlight] in text.
var bbcode := "highlight"

func _process_custom_fx(char_fx):
	var frequency: float = char_fx.env.get("freq", 6.0)
	var amplitude: float = char_fx.env.get("amplitude", 3.0)
	
	char_fx.offset = Vector2.UP * abs(sin(char_fx.elapsed_time * frequency)) * amplitude

	return true
