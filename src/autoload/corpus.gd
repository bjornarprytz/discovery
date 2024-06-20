extends Node2D
class_name CorpusClass

const font_size: Vector2 = Vector2(32.0, 64.0)

const corpus_line_length: int = 128
## How many characters per line in a segment
const segment_width: int = 48
## How many lines of text in a segment
const segment_height: int = 12

class FullText: # This should probably be called Corpus
    var chapters: Array[Chapter]
    var full_length: int
    var valid_regex: RegEx = RegEx.new()

    func _init(chapters_: Array[Chapter]):
        valid_regex.compile("\\w+")
        chapters = chapters_
        full_length = 0
        for chapter in chapters:
            full_length += chapter.length
    
    func length():
        return full_length

    func get_words() -> Array[String]:
        var words: Array[String] = []
        for c in chapters:
            for w in valid_regex.search_all(c.text):
                var word = w.get_string().to_lower()
                words.push_back(word)
        
        return words

    func normalize_idx(idx: int) -> int:
        var n = idx % full_length
        while n < 0:
            n += full_length
        
        return n

    func get_chapter_at(idx: int) -> Chapter:
        var normalized_idx = normalize_idx(idx)
        for chapter in chapters:
            if normalized_idx < chapter.length:
                return chapter
            normalized_idx -= chapter.length
        
        push_error("Index out of bounds")
        return null

    func get_char_at(idx: int) -> String:
        var normalized_idx = normalize_idx(idx)
        
        for chapter in chapters:
            if normalized_idx < chapter.length:
                return chapter.text[normalized_idx]
            normalized_idx -= chapter.length
        
        push_error("Index out of bounds")
        return "NONE"
    
    func is_char_valid(letter: String) -> bool:
        return valid_regex.search(letter) != null

    func is_char_valid_at(idx: int) -> bool:
        return is_char_valid(get_char_at(idx))
    
class Chapter:
    var number: int
    var title: String
    var text: String
    var length: int

    func _init(number_: int, title_: String, text_: String):
        number = number_
        title = title_
        text = text_
        text = text.replace("\n", " ").replace("  ", " ") + " " # Add space to separate the last and first words

        length = text.length()

class WordData:
    var word: String
    var start_idx: int
    var states: Array[CharState] = []

    func is_completed():
        if states.size() == 0:
            return false
        var each_character_visited = states.all(func(s: CharState) -> bool:
            return s.visited or s.quest
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

var words: Array[String] = []
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
    return corpus.is_char_valid(letter)

func get_state(idx: int) -> CharState:
    var normalized_idx = normalize_idx(idx)
    if (!state.has(normalized_idx)):
        state[normalized_idx] = CharState.new()
        
    state[normalized_idx].impassable = !corpus.is_char_valid_at(idx)
    state[normalized_idx].corpus_idx = normalized_idx
        
    return state[normalized_idx]

func get_char_at(idx: int) -> String:
    var normalized_idx = normalize_idx(idx)
    
    return corpus.get_char_at(normalized_idx)

func get_word_of(idx: int) -> WordData:
    var normalized_idx: int = normalize_idx(idx)
    var letter = corpus.get_char_at(idx)
    if (corpus.is_char_valid(letter) == false):
        return null
    
    var data = WordData.new()
    
    var start := ""
    var end := ""
    
    var pointer := normalized_idx + 1
    
    while corpus.is_char_valid(letter):
        end += letter
        data.states.push_back(get_state(pointer - 1))
        letter = corpus.get_char_at(pointer)
        pointer += 1
    
    pointer = normalized_idx - 1
    letter = corpus.get_char_at(pointer)
    while corpus.is_char_valid(letter):
        start = letter + start
        data.states.push_front(get_state(pointer))
        pointer -= 1
        letter = corpus.get_char_at(pointer)
    
    data.start_idx = pointer + 1
    data.word = start + end
    
    var i := 0
    for s in data.states:
        s.local_idx = i
        i += 1
    
    return data

func normalize_idx(idx: int) -> int:
    return corpus.normalize_idx(idx)

func load_corpus(text: String="", save: bool=true):
    assert(segment_width <= corpus_line_length)
    assert(segment_height > 0)
    assert(segment_width > 0)
    
    if (text.length() > 0):
        corpus = FullText.new([Chapter.new(0, "CustomCorpus", text)])
    else:
        corpus = AlicesAdventuresInWonderland.create_corpus()
    
    if (save):
        main_corpus = corpus # Store it for later
    
    lengthOfLongestWord = 0
    words = []
    for w in corpus.get_words():
        words.push_back(w)
        if w.length() > lengthOfLongestWord:
            lengthOfLongestWord = w.length()
    
    state = {}

@onready var main_corpus: FullText
