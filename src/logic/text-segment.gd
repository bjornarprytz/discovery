extends RichTextLabel
class_name TextSegment

var start_index : int

var t : RichTextEffect

func set_start_index(idx: int) -> void:
	var normalized_idx = Corpus.normalize_idx(idx)
	start_index = normalized_idx
	refresh()

func contains_idx(idx: int) -> bool:	
	var normalized_idx = Corpus.normalize_idx(idx)
	
	for l in range(Corpus.segment_height):
		var line_idx = start_index + (l * Corpus.corpus_line_length)
		
		if (line_idx <= normalized_idx and normalized_idx < line_idx + Corpus.segment_width):
			return true
			
	return false

func refresh() -> void:
	clear()
	for line in range(Corpus.segment_height):
		_append_line(start_index + (line * Corpus.corpus_line_length))

func _append_line(idx: int) -> void:
	var normalized_idx = Corpus.normalize_idx(idx)
	
	for pos in range(Corpus.segment_width):
		var char_idx = normalized_idx + pos
		var letter = Corpus.get_char_at(char_idx)
		var char_state = Corpus.get_state(char_idx) as CorpusClass.CharState
		
		var pushed_effect := false
		
		var trailing_space:bool = letter == " " and !char_state.cursor and (pos == 0 or pos == Corpus.segment_width-1)
		if trailing_space:
			# Hack to get around trailing spaces being removed in BBCode
			letter = "_"
			push_color(Color.from_hsv(0,0,0,0))
		
		var base_color : Color = Game.MARK_COLOR
		if (char_state.quest):
			base_color = Game.QUEST_COLOR
		
		if (char_state.cursor):
			if (letter == " "):
				letter = "_"
			push_customfx(Cursor.new(), { "color": base_color })
			pushed_effect = true
		elif (char_state.impassable):
			pass
		elif (char_state.completed_word):
			var word = Corpus.get_word_of(char_idx)
			push_customfx(Quest.new(), { "idx": char_state.local_idx, "len": word.word.length(), "color": base_color })
			pushed_effect = true
		elif (char_state.quest):
			push_color(Game.QUEST_COLOR)
			pushed_effect = true
		elif(char_state.visited):
			push_color(Game.MARK_COLOR)
			pushed_effect = true
		elif (char_state.invalid_move):
			push_customfx(Error.new(),{})
			pushed_effect = true
		
		append_text(letter)
		
		if pushed_effect:
			pop()
		if trailing_space:
			pop()

