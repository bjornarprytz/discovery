@tool
class_name Quest
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [Quest param=2.0]hello[/Quest] in text.
var bbcode := "quest"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var param: float = char_fx.env.get("param", 1.0)
	
	# TODO: Add quest effect
	return true
