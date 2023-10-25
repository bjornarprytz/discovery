class_name Cursor
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [cursor param=2.0]hello[/cursor] in text.
var bbcode := "cursor"
const CURSOR = "█"
const CURSOR_COLOR = Color.GREEN_YELLOW

func _process_custom_fx(char_fx):
	var frequency: float = char_fx.env.get("freq", 6.0)
	var off_color: Color = char_fx.env.get("off_color", Color.from_hsv(0,0,0,0))
	var on_color: Color = char_fx.env.get("color", Corpus.MARK_COLOR)
	
	if (sin(char_fx.elapsed_time * frequency) > 0.0):
		char_fx.color = off_color
	else:
		char_fx.color = on_color
	return true
