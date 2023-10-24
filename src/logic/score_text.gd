extends Node2D
class_name ScoreTextGame

@onready var segment_spawner = preload("res://logic/text-segment.tscn")
@onready var LINE_LENGTH : int = Global.corpus_line_length
@onready var SEGMENT_HEIGHT : int = Global.segment_height * Global.corpus_line_length
@onready var SEGMENT_WIDTH : int = Global.segment_width

var current_pos : int = 0

var up : MoveCandidate
var right : MoveCandidate
var down : MoveCandidate
var left : MoveCandidate

class MoveCandidate:
	var destination : int
	var character: String
	var state: Corpus.CharState
	var step : Vector2

func _ready() -> void:
	Global.load_corpus("Restart ------------------------------------------------------- 
Quit ---------------------------------------------------------- 
-pun > word---------------------------------------------------
	")
		
	var segment = segment_spawner.instantiate() as TextSegment
	segment.set_start_index(0)
	add_child(segment)
	
	_visit(0)
	_refresh_text()

func try_move(input : String) -> bool:
	if (input.length() > 1):
		return true 
	
	var visited = [up, right, down, left].filter(func (c: MoveCandidate): return c.state.visited)
	var not_visited = [up, right, down, left].filter(func (c: MoveCandidate): return !c.state.visited)
	
	var invalid = not_visited.filter(func (c1: MoveCandidate): return not_visited.filter(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0).size() > 1)
	var valid = not_visited.filter(func (c: MoveCandidate): return Global.valid_regex.search(c.character) != null).filter(func (c1: MoveCandidate): return !invalid.any(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0))
	
	if valid.is_empty():
		Global.game_over.emit()
	
	for candidate in valid:
		if (input.nocasecmp_to(candidate.character) == 0):
			var score = _visit(candidate.destination)
			Global.moved.emit(candidate.step, score)
			
	if invalid.any(func (cand: MoveCandidate): return input.nocasecmp_to(cand.character) == 0):
		for d in invalid:
			Global.get_state((d as MoveCandidate).destination).invalid_move = true
		_refresh_text()
		return false
	
	_refresh_text()
	return true

func _visit(target_idx: int) -> int:
	var prev_state = Global.get_state(current_pos) as Corpus.CharState
	prev_state.cursor = false
	prev_state.visited = true
	
	var next_state = Global.get_state(target_idx) as Corpus.CharState
	next_state.cursor = true
	
	current_pos = target_idx
	var score = 1 # Base score for moving
	
	var word = Global.get_word_of(target_idx) as Corpus.WordData
	
	if (word != null and word.states.all(func (s : Corpus.CharState): return s.visited or s.cursor)):
		Global.completed_quest.emit(word.word)
	
	for c in [up, right, down, left]:
		if (c != null):
			c.state.invalid_move = false
	
	up = _create_candidate(current_pos - LINE_LENGTH, Global.font_size * Vector2.UP)
	right = _create_candidate(current_pos +1, Global.font_size * Vector2.RIGHT)
	down = _create_candidate(current_pos + LINE_LENGTH, Global.font_size * Vector2.DOWN)
	left = _create_candidate(current_pos -1,  Global.font_size * Vector2.LEFT)
	
	return score

func _refresh_text():
	for s in get_children():
		(s as TextSegment).refresh()

func _create_candidate(target_idx: int, step: Vector2) -> MoveCandidate:
	var candidate = MoveCandidate.new()
	candidate.character = Global.get_char_at(target_idx)
	candidate.destination = target_idx
	candidate.state = Global.get_state(target_idx)
	candidate.step = step
	return candidate
