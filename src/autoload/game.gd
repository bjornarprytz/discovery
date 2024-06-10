extends Node2D
class_name GameClass

signal moved(prev_pos: int, current_pos: int, direction: Vector2, score_change: int)
signal multiplier_changed(new_value: int)
signal invalid_move()
signal quest_duration_tick(duration: int, cap: int)
signal completed_word(word: String, was_quest: bool)
signal new_target(word: String)
signal golden_changed(is_golden: bool)
signal game_over(score: int)

const ERROR_COLOR: Color = Color.CRIMSON
const MARK_COLOR: Color = Color.AQUAMARINE
const QUEST_COLOR: Color = Color.GOLDENROD
const INERT_COLOR: Color = Color.DIM_GRAY

const QUEST_MULTIPLIER: int = 4
# How many vertical moves a quest word can take before it expires
const QUEST_DURATION_FACTOR: int = 4

var current_target: String
var is_golden: bool = true:
	set(value):
		if (value != is_golden):
			is_golden = value
			golden_changed.emit(is_golden)

var quest_duration := 0
var current_pos := 0
var score := 0
var multiplier: int = 1:
	set(value):
		if (value != multiplier):
			multiplier = value
			multiplier_changed.emit(multiplier)

var up: MoveCandidate
var right: MoveCandidate
var down: MoveCandidate
var left: MoveCandidate

class MoveCandidate:
	var destination: int
	var character: String
	var state: CorpusClass.CharState
	var direction: Vector2

	func _init(target_idx: int, direction_: Vector2):
		character = Corpus.get_char_at(target_idx)
		destination = target_idx
		state = Corpus.get_state(target_idx)
		direction = direction_

func start(corpus: String=""):
	score = 0
	quest_duration = 0
	multiplier = 1
	Corpus.load_corpus(corpus)
	cycle_target()

func cycle_target():
	if (Corpus.words.is_empty()):
		Game.game_over.emit(Game.score)
		return
	current_target = Corpus.words.pop_front()
	_reset_quest_duration()
	Game.new_target.emit(current_target)

func try_move(input: String) -> bool:
	if (input.length() > 1):
		return false
	
	_reset_word_state()

	var visited = [up, right, down, left].filter(func(c: MoveCandidate): return c.state.visited)
	var not_visited = [up, right, down, left].filter(func(c: MoveCandidate): return !c.state.visited)
	
	var invalid = not_visited.filter(func(c1: MoveCandidate): return not_visited.filter(func(c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0).size() > 1)
	var valid = not_visited.filter(func(c: MoveCandidate): return Corpus.valid_regex.search(c.character) != null).filter(func(c1: MoveCandidate): return !invalid.any(func(c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0))
	
	if valid.is_empty():
		for d in invalid:
			Corpus.get_state((d as MoveCandidate).destination).invalid_move = true
		Game.invalid_move.emit()
		Game.game_over.emit(Game.score)

	for candidate in valid:
		if (input.nocasecmp_to(candidate.character) == 0):
			var prev_pos = current_pos
			var score_change = _visit(candidate.destination)
			score += score_change
			Game.moved.emit(prev_pos, current_pos, candidate.direction, score_change)
			if (candidate.direction == Vector2.UP or candidate.direction == Vector2.DOWN):
				_tick_quest_duration()
			return true
			
	if invalid.any(func(cand: MoveCandidate): return input.nocasecmp_to(cand.character) == 0):
		for d in invalid:
			Corpus.get_state((d as MoveCandidate).destination).invalid_move = true
		Game.invalid_move.emit()
	
	return false

func force_move(target_pos: int, first_move: bool):
	var prev_pos = current_pos
	var score_change = _visit(target_pos, first_move)
	Game.moved.emit(prev_pos, current_pos, Vector2.ZERO, score_change)

func _ready() -> void:
	start()
	Game.completed_word.connect(_on_word_complete)

func _reset_word_state():
	var word = Corpus.get_word_of(current_pos) as CorpusClass.WordData
	if (word != null and word.states.all(func(s: CorpusClass.CharState): return s.visited or s.cursor)):
		for s in word.states:
			s.completed_word = false

func _on_word_complete(_word: String, was_quest: bool):
	if (was_quest):
		cycle_target()
	
func _reset_quest_duration():
	quest_duration = current_target.length() * QUEST_DURATION_FACTOR
	Game.quest_duration_tick.emit(quest_duration, quest_duration)

func _tick_quest_duration():
	quest_duration -= 1
	if (quest_duration <= 0):
		is_golden = false
		cycle_target()
	else:
		Game.quest_duration_tick.emit(quest_duration, current_target.length() * QUEST_DURATION_FACTOR)

func _visit(target_idx: int, first_move: bool=false) -> int:
	if (!first_move):
		var prev_state = Corpus.get_state(current_pos) as CorpusClass.CharState
		prev_state.cursor = false
		prev_state.visited = true
	
	var next_state = Corpus.get_state(target_idx) as CorpusClass.CharState
	next_state.cursor = true
	
	current_pos = target_idx
	var score_change = 1 # Base score for moving

	var word = Corpus.get_word_of(target_idx) as CorpusClass.WordData
	
	if (word != null and word.states.all(func(s: CorpusClass.CharState): return s.visited or s.cursor)):
		score_change += word.word.length()
		score_change *= multiplier
		var is_target = current_target.nocasecmp_to(word.word) == 0
		
		for s in word.states:
			s.completed_word = true
			if (is_target):
				s.quest = true
		
		if (is_target):
			score_change *= QUEST_MULTIPLIER
			is_golden = true
		
		if (is_golden):
			multiplier += 1
		Game.completed_word.emit(word.word, is_target)
	
	for c in [up, right, down, left]:
		if (c != null):
			c.state.invalid_move = false
	
	up = MoveCandidate.new(current_pos - Corpus.corpus_line_length, Vector2.UP)
	right = MoveCandidate.new(current_pos + 1, Vector2.RIGHT)
	down = MoveCandidate.new(current_pos + Corpus.corpus_line_length, Vector2.DOWN)
	left = MoveCandidate.new(current_pos - 1, Vector2.LEFT)

	return score_change
