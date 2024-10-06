extends Node2D
class_name CorpusClass

const font_size: Vector2 = Vector2(32.0, 64.0)

const corpus_line_length: int = 128
## How many characters per line in a segment
const segment_width: int = 48
## How many lines of text in a segment
const segment_height: int = 12

class FullText: # This should probably be called Corpus
	var title: String
	var chapters: Array[Chapter]
	var full_length: int
	var longest_word_length: int = 0

	var _index_ratio: float = 0.0

	var words: Array[String] = []

	func _init(title_: String, chapters_: Array[Chapter]):
		title = title_
		chapters = chapters_
		full_length = 0
		for chapter in chapters:
			chapter.start_index = full_length
			full_length += chapter.length
		
		_index_ratio = chapters.size() / float(full_length)
		
		longest_word_length = 0
		for c in chapters:
			for w in Validation.get_matches(c.text):
				var word = w.get_string().to_lower()
				words.push_back(word)
				if word.length() > longest_word_length:
					longest_word_length = word.length()
	
	func length():
		return full_length

	func get_word_of(idx: int) -> WordData:
		var normalized_idx = normalize_idx(idx)
		
		var chapter = get_chapter_at(normalized_idx)

		var word = chapter.get_word_of(normalized_idx)
		
		return word

	func normalize_idx(idx: int) -> int:
		var n = idx % full_length
		while n < 0:
			n += full_length
		
		return n

	func _get_approx_chapter_at(idx: int) -> int:
		var approx_chapter_idx: int = idx * _index_ratio
		return approx_chapter_idx

	func get_chapter_at(idx: int) -> Chapter:
		var normalized_idx = normalize_idx(idx)

		var approx_chapter_idx = _get_approx_chapter_at(normalized_idx)

		var chapter_candidate = chapters[approx_chapter_idx]

		while chapter_candidate.contains_index(normalized_idx) == false:
			if chapter_candidate.start_index > normalized_idx:
				approx_chapter_idx -= 1
			else:
				approx_chapter_idx += 1
			chapter_candidate = chapters[approx_chapter_idx]
		
		return chapter_candidate

	func get_char_at(idx: int) -> String:
		var normalized_idx = normalize_idx(idx)
		
		var chapter = get_chapter_at(normalized_idx)
		var local_idx = normalized_idx - chapter.start_index
		return chapter.text[local_idx]

	func is_char_valid_at(idx: int) -> bool:
		return Validation.is_char_valid(get_char_at(idx))
	
class Chapter:
	var number: int
	var title: String
	var text: String
	var _end_index: int = -1
	var start_index: int = -1:
		set(value):
			if length == 0:
				push_error("Cannot set start_index before setting length")

			if start_index == -1:
				start_index = value
				_end_index = start_index + length
			else:
				push_error("Cannot set start_index twice")

	var length: int

	func _init(number_: int, title_: String, text_: String):
		number = number_
		title = title_
		text = text_
		text = text.replace("\n", " ").replace("  ", " ") + " " # Add space to separate the last and first words

		length = text.length()

		assert(length > 0, "Chapter text must be non-empty")

	func contains_index(idx: int):
		return start_index <= idx and idx < _end_index

	func get_word_of(normalized_idx: int) -> WordData:
		var local_idx = normalized_idx - start_index
		var letter = text[local_idx]
		if Validation.is_char_valid(letter) == false:
			return null
		
		var local_start_idx = local_idx # This will land on the first letter of the word
		var local_end_idx = local_idx # This will land on the first invalid character after the word

		while local_end_idx < length and Validation.is_char_valid(text[local_end_idx]):
			local_end_idx += 1
		
		while local_start_idx > 0 and Validation.is_char_valid(text[local_start_idx - 1]):
			local_start_idx -= 1
		
		var data = WordData.new()
		data.start_idx = local_start_idx + start_index
		data.word = text.substr(local_start_idx, (local_end_idx - local_start_idx))

		return data

class WordData:
	var word: String
	var start_idx: int
	var states: Array[CharState] = []

	func is_quest():
		return states.size() > 0 and states[0].quest

	func is_completed():
		if states.size() == 0:
			return false
		var each_character_visited = states.all(func(s: CharState) -> bool:
			return s.visited or s.quest or s.cursor
		)
		
		return each_character_visited

class CharState:
	var visited: bool
	var cursor: bool
	var highlight: bool # For tutorial
	var impassable: bool
	var invalid_move: bool
	# Used for the effect of completing a worod
	var completed_word: bool
	var quest: bool
	var local_idx: int # Only relevant for words
	var corpus_idx: int

var state: Dictionary = {}

var lengthOfLongestWord: int = 0

var corpus: FullText

func get_chapter_at(idx: int) -> Chapter:
	var normalized_idx = normalize_idx(idx)
	for chapter in corpus.chapters:
		if normalized_idx < chapter.length:
			return chapter
		normalized_idx -= chapter.length
	
	push_error("Index out of bounds")
	return null

func is_char_valid(letter: String) -> bool:
	return Validation.is_char_valid(letter)

func get_state(idx: int) -> CharState:
	var normalized_idx = normalize_idx(idx)
	if (!state.has(normalized_idx)):
		state[normalized_idx] = CharState.new()
		state[normalized_idx].impassable = !corpus.is_char_valid_at(idx)
		state[normalized_idx].corpus_idx = normalized_idx
		
	return state[normalized_idx]

func get_char_at(idx: int) -> String:
	return corpus.get_char_at(idx)

func get_word_of(idx: int) -> WordData:
	var data = corpus.get_word_of(idx)

	if data == null:
		return null
	
	for i in range(data.word.length()):
		var local_state = get_state(i + data.start_idx)
		local_state.local_idx = i
		data.states.push_back(local_state)

	return data

func normalize_idx(idx: int) -> int:
	return corpus.normalize_idx(idx)

func longest_word_length():
	return corpus.longest_word_length

func get_words() -> Array[String]:
	return corpus.words

func load_corpus(text: FullText, save: bool = true):
	assert(segment_width <= corpus_line_length)
	assert(segment_height > 0)
	assert(segment_width > 0)
	
	if (text == null):
		text = AlicesAdventuresInWonderland.create_corpus() # Default to Alice's Adventures in Wonderland

	corpus = text

	if (save):
		main_corpus = corpus # Store it for later
	
	state = {}

@onready var main_corpus: FullText
