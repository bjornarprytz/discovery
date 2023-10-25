extends Node2D
class_name GameClass


signal moved(prev_pos: int, current_pos: int, direction: Vector2, score_change: int)
signal multiplier_changed(new_value: int)
signal before_moving()
signal invalid_move()
signal fatigue_tick(fatigue: int, cap: int)
signal completed_quest(word: String)
signal new_target(word: String)
signal game_over

const ERROR_COLOR: Color = Color.CRIMSON
const MARK_COLOR: Color = Color.AQUAMARINE
const QUEST_COLOR: Color = Color.GOLDENROD
const IMPASSABLE_COLOR: Color = Color.LIGHT_GRAY

const QUEST_MULTIPLIER: int = 4
const FATIGUE_FACTOR: int = 5

var current_target : String
var word_fatigue := 0
var current_pos := 0
var score := 0
var multiplier := 1

var up : MoveCandidate
var right : MoveCandidate
var down : MoveCandidate
var left : MoveCandidate

class MoveCandidate:
	var destination : int
	var character: String
	var state: CorpusClass.CharState
	var direction : Vector2

func cycle_target():
	current_target = Corpus.words.pop_front()
	_reset_fatigue()
	new_target.emit(current_target)

func try_move(input : String):
	if (input.length() > 1):
		return
	
	before_moving.emit()

	var visited = [up, right, down, left].filter(func (c: MoveCandidate): return c.state.visited)
	var not_visited = [up, right, down, left].filter(func (c: MoveCandidate): return !c.state.visited)
	
	var invalid = not_visited.filter(func (c1: MoveCandidate): return not_visited.filter(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0).size() > 1)
	var valid = not_visited.filter(func (c: MoveCandidate): return Corpus.valid_regex.search(c.character) != null).filter(func (c1: MoveCandidate): return !invalid.any(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0))
	
	if valid.is_empty():
		Game.game_over.emit()
	
	for candidate in valid:
		if (input.nocasecmp_to(candidate.character) == 0):
			var prev_pos = current_pos
			var score_change = _visit(candidate.destination)
			score += score_change
			Game.moved.emit(prev_pos, current_pos, candidate.direction, score_change)
			if (candidate.direction == Vector2.UP or candidate.direction == Vector2.DOWN):
				_tick_fatigue()
			return
			
	if invalid.any(func (cand: MoveCandidate): return input.nocasecmp_to(cand.character) == 0):
		for d in invalid:
			Corpus.get_state((d as MoveCandidate).destination).invalid_move = true
		invalid_move.emit()

func force_move(target_pos: int):
	var prev_pos = current_pos
	var score_change = _visit(target_pos)
	Game.moved.emit(prev_pos, current_pos, Vector2.ZERO, score_change)

func _ready() -> void:
	Corpus.load_corpus()
	completed_quest.connect(_on_quest_complete)
	cycle_target()

func _on_quest_complete(word: String):
	cycle_target()

func _reset_fatigue():
	word_fatigue = current_target.length() * FATIGUE_FACTOR
	fatigue_tick.emit(word_fatigue, word_fatigue)

func _tick_fatigue():
	if (multiplier > 1):
		multiplier -= 1

	var prev_fatigue = word_fatigue
	word_fatigue -= 1
	if (word_fatigue <= 0):
		cycle_target()
	else:
		fatigue_tick.emit(word_fatigue, current_target.length() * FATIGUE_FACTOR)

func _visit(target_idx: int) -> int:
	var prev_state = Corpus.get_state(current_pos) as CorpusClass.CharState
	prev_state.cursor = false
	prev_state.visited = true
	
	var next_state = Corpus.get_state(target_idx) as CorpusClass.CharState
	next_state.cursor = true
	
	current_pos = target_idx
	var score_change = 1 # Base score for moving

	var word = Corpus.get_word_of(target_idx) as CorpusClass.WordData
	
	if (word != null and word.states.all(func (s : CorpusClass.CharState): return s.visited or s.cursor)):
		score_change += word.word.length()
		score_change *= multiplier
		multiplier = max(multiplier, word.word.length())
		var is_target = current_target.nocasecmp_to(word.word) == 0
		
		for s in word.states:
			s.completed_word = true
			if (is_target):
				s.quest = true
		
		if (is_target):
			completed_quest.emit(word.word)
			score_change *= QUEST_MULTIPLIER
	
	for c in [up, right, down, left]:
		if (c != null):
			c.state.invalid_move = false
	
	up = _create_candidate(current_pos - Corpus.corpus_line_length, Vector2.UP)
	right = _create_candidate(current_pos +1, Vector2.RIGHT)
	down = _create_candidate(current_pos + Corpus.corpus_line_length, Vector2.DOWN)
	left = _create_candidate(current_pos -1, Vector2.LEFT)

	return score_change


func _create_candidate(target_idx: int, direction: Vector2) -> MoveCandidate:
	var candidate = MoveCandidate.new()
	candidate.character = Corpus.get_char_at(target_idx)
	candidate.destination = target_idx
	candidate.state = Corpus.get_state(target_idx)
	candidate.direction = direction
	return candidate
