@tool
class_name Error
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [error param=2.0]hello[/error] in text.
var bbcode := "error"

var _word = 0.0


func _process_custom_fx(char_fx):
	if char_fx.relative_index == 0:
		_word = 0
	
	var scale: float = char_fx.env.get("scale", 10.0)
	var freq: float = char_fx.env.get("freq", 100.0)
	var duration: float = char_fx.env.get("duration", .2)
	var color = Color(char_fx.env.get("color", Refs.error_color))
	
	var time_remaining = duration - char_fx.elapsed_time
	
	char_fx.color = color
	
	if (duration > 0.0 and time_remaining < 0.0):
		return true
	
	var s = fmod((_word + char_fx.elapsed_time) * PI * 1.25, PI * 2.0)
	var p = sin(char_fx.elapsed_time * freq)
	char_fx.offset.x += sin(s) * p * scale
	char_fx.offset.y += cos(s) * p * scale
	
	return true
