extends RichTextLabel
class_name TextSegment

var start_index : int

var t : RichTextEffect

func set_start_index(idx: int) -> void:
	var normalized_idx = Global.normalize_idx(idx)
	start_index = normalized_idx
	refresh()
	

func contains_idx(idx: int) -> bool:	
	var normalized_idx = Global.normalize_idx(idx)
	
	for l in range(Global.segment_height):
		var line_idx = start_index + (l * Global.corpus_line_length)
		
		if (line_idx <= normalized_idx and normalized_idx < line_idx + Global.segment_width):
			return true
			
	return false

func refresh() -> void:
	clear()
	for l in range(Global.segment_height):
		_append_line(start_index + (l * Global.corpus_line_length))

func _append_line(idx: int) -> void:
	var normalized_idx = Global.normalize_idx(idx)
	
	var prev_state: Corpus.CharState = Corpus.CharState.new()
	
	for pos in range(Global.segment_width):
		var char_idx = normalized_idx + pos
		var letter = Global.get_char_at(char_idx)
		var char_state = Global.get_state(char_idx) as Corpus.CharState
		
		if (char_state.visited and !prev_state.visited):
			push_color(Global.MARK_COLOR)
		if (!char_state.visited and prev_state.visited):
			pop()
		
		var trailing_space:bool = letter == " " and (pos == 0 or pos == Global.segment_width-1)
		# Hack to get around trailing spaces being removed in BBCode
		if trailing_space:
			letter = "_"
			push_color(Color.from_hsv(0,0,0,0))
		
		var pushed_effect := false
		
		if (char_state.quest):
			push_customfx(Quest.new(), { })
			pushed_effect = true
		elif (char_state.cursor):
			push_customfx(Cursor.new(), { "color": Global.MARK_COLOR })
			pushed_effect = true
		elif (char_state.invalid_move):
			push_customfx(Error.new(),{})
			pushed_effect = true
		elif (char_state.impassable):
			push_color(Global.IMPASSABLE_COLOR)
			pushed_effect = true
		
		append_text(letter)
		
		if pushed_effect:
			pop()
		if trailing_space:
			pop()
		
		prev_state = char_state

	if (prev_state.visited):
		pop()

