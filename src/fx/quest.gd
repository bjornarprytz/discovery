@tool
class_name Quest
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [Quest param=2.0]hello[/Quest] in text.
var bbcode := "quest"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var idx: int = char_fx.env.get("idx", 0)
	var duration: float = char_fx.env.get("dur", .3)
	var magnitude: float = char_fx.env.get("mag", 20.0)
	var word_length: int = char_fx.env.get("len", 3)
	var color : Color = char_fx.env.get("color", Game.MARK_COLOR)
	
	var delay = idx * duration / word_length
	var delay_time = delay - char_fx.elapsed_time
	char_fx.color = color
	
	if (delay_time > 0.0):
		return true
	
	var effect_time_remaining = delay_time + duration
	
	if (effect_time_remaining < 0.0):
		char_fx.offset = Vector2(0.0,0.0)
		return true
		
	
	var t = abs(sin((effect_time_remaining / duration) * PI)) * magnitude
	char_fx.offset.y -= t
	return true
