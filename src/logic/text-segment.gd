extends RichTextLabel
class_name TextSegment

var start_index : int

var t : RichTextEffect

func set_start_index(idx: int) -> void:
	var normalized_idx = Autoload.normalize_idx(idx)
	start_index = normalized_idx
	refresh()
	

func contains_idx(idx: int) -> bool:	
	var normalized_idx = Autoload.normalize_idx(idx)
	
	for l in range(Autoload.segment_height):
		var line_idx = start_index + (l * Autoload.corpus_line_length)
		
		if (line_idx <= normalized_idx and normalized_idx < line_idx + Autoload.segment_width):
			return true
			
	return false

func refresh() -> void:
	clear()
	push_bgcolor(Color.from_string("050f26", Color.PURPLE))
	for l in range(Autoload.segment_height):
		_append_line(start_index + (l * Autoload.corpus_line_length))
	pop()

func _append_line(idx: int) -> void:
	var normalized_idx = Autoload.normalize_idx(idx)
	var is_marking : bool
	
	for pos in range(Autoload.segment_width):
		var char_idx = normalized_idx + pos
		var letter = Autoload.get_char_at(char_idx)
		var is_visited = Autoload.is_visited(char_idx)
		
		if (is_visited and !is_marking):
			is_marking = true
			push_color(Autoload.MARK_COLOR)
		if (!is_visited and is_marking):
			is_marking = false
			pop()
		
		# Hack to get around trailing spaces being removed in BBCode
		var is_trailing_space = letter == " " and (pos == 0 or pos == Autoload.segment_width-1)
		
		if is_trailing_space:
			letter = "a"
			push_color(Color.from_hsv(0,0,0,0))
		
		append_text(letter)
		if (is_trailing_space):
			pop()

	if (is_marking):
		pop()

