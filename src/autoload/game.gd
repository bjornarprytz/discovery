extends Node2D
class_name GameClass

signal ready_to_move
signal moved(prev_pos: int, current_pos: int, direction: Vector2, score_change: int)
signal multiplier_changed(new_value: int)
signal invalid_move()
signal quest_duration_tick(duration: int, cap: int)
signal completed_word(word: String, was_quest: bool)
signal new_quest(word: String)
signal golden_changed(is_golden: bool)
signal game_over(stats: Stats)
signal new_chapter(chapter: CorpusClass.Chapter)
signal mute_toggled(muted: bool)

const QUEST_MULTIPLIER: int = 4

# How much the distance affects the quest duration
const QUEST_DISTANCE_FACTOR: int = 2

class Stats:
	var score: int
	var multiplier: int
	var moves_while_golden: int
	var vertical_moves: int
	var traversed_characters: Array[CorpusClass.CharState] = []
	var completed_words: Array[CorpusClass.WordData] = []
	
	func _init():
		score = 0
		multiplier = 1
		moves_while_golden = 0
	
	func completed_quests() -> Array[CorpusClass.WordData]:
		return completed_words.filter(func(w: CorpusClass.WordData): return w.is_quest() and w.is_completed())

	func ratio_of_characters_completed_words() -> float:
		if traversed_characters.size() == 0:
			return 0.0
		var completed_chars = traversed_characters.filter(func(c: CorpusClass.CharState): return c.completed_word)
		return completed_chars.size() / float(traversed_characters.size())
	
	func ratio_of_moves_while_golden() -> float:
		if (moves_while_golden == 0):
			return 0.0
		return moves_while_golden / float(traversed_characters.size())
	
	func ratio_of_quests_to_words() -> float:
		if (completed_words.size() == 0):
			return 0.0
		var quests = completed_quests()
		return quests.size() / float(completed_words.size())

var stats: Stats = Stats.new()

var is_muted: bool:
	set(value):
		if value != is_muted:
			is_muted = value
			mute_toggled.emit(is_muted)
var current_quest: String
var is_golden: bool = true:
	set(value):
		if (value != is_golden):
			is_golden = value
			golden_changed.emit(is_golden)

var quest_duration := 0
var quest_cap := 0
var current_pos := 0
var score := 0:
	get:
		return stats.score
	set(value):
		if (value != score):
			score = value
		stats.score = value
var multiplier: int = 1:
	get:
		return stats.multiplier
	set(value):
		if (value != multiplier):
			multiplier = value
			multiplier_changed.emit(multiplier)
		stats.multiplier = value

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

func start(corpus: CorpusClass.FullText):
	is_golden = true
	score = 0
	quest_duration = 0
	multiplier = 1
	stats = Stats.new()
	Corpus.load_corpus(corpus)

func try_move(input: String) -> bool:
	if (input.length() > 1):
		return false
	
	_reset_word_state()

	var visited = [up, right, down, left].filter(func(c: MoveCandidate): return c.state.visited)
	var not_visited = [up, right, down, left].filter(func(c: MoveCandidate): return !c.state.visited)
	
	var invalid = not_visited.filter(func(c1: MoveCandidate): return not_visited.filter(func(c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0).size() > 1)
	var valid = not_visited.filter(func(c: MoveCandidate): return Corpus.is_char_valid(c.character)).filter(func(c1: MoveCandidate): return !invalid.any(func(c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0))
	
	if valid.is_empty():
		for d in invalid:
			Corpus.get_state((d as MoveCandidate).destination).invalid_move = true
		Game.invalid_move.emit()
		Game.game_over.emit(Game.stats)

	for candidate in valid:
		if (input.nocasecmp_to(candidate.character) == 0):
			var prev_pos = current_pos
			var score_change = _visit(candidate.destination)
			score += score_change
			Game.moved.emit(prev_pos, current_pos, candidate.direction, score_change)
			if (candidate.direction == Vector2.UP or candidate.direction == Vector2.DOWN):
				_tick_quest_duration()
				stats.vertical_moves += 1
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
	start(Corpus.main_corpus)
	Game.completed_word.connect(_on_word_complete)

func _reset_word_state():
	var word = Corpus.get_word_of(current_pos) as CorpusClass.WordData
	if (word != null and word.states.all(func(s: CorpusClass.CharState): return s.visited or s.cursor)):
		for s in word.states:
			s.completed_word = false

func _on_word_complete(_word: String, was_quest: bool):
	if (was_quest):
		_cycle_quest()
	
func _reset_quest_duration(distance: int):
	quest_cap = distance + current_quest.length()
	quest_duration = quest_cap
	Game.quest_duration_tick.emit(quest_duration, quest_cap)

func _tick_quest_duration():
	quest_duration -= 1
	if (quest_duration <= 0):
		is_golden = false
		_cycle_quest()
	Game.quest_duration_tick.emit(quest_duration, quest_cap)

func _visit(target_idx: int, first_move: bool = false) -> int:
	if (!first_move):
		var prev_state = Corpus.get_state(current_pos) as CorpusClass.CharState
		prev_state.cursor = false
		prev_state.visited = true
	
	var next_state = Corpus.get_state(target_idx) as CorpusClass.CharState
	next_state.cursor = true
	
	stats.traversed_characters.append(next_state)
	if (is_golden):
		stats.moves_while_golden += 1

	current_pos = target_idx
	var score_change = 1 # Base score for moving
	if (first_move):
		_cycle_quest()

	var word = Corpus.get_word_of(target_idx) as CorpusClass.WordData
	
	if (word != null and word.is_completed()):
		score_change += word.word.length()
		score_change *= multiplier
		var is_target = current_quest.nocasecmp_to(word.word) == 0
		
		for s in word.states:
			s.completed_word = true
			if (is_target):
				s.quest = true
		
		if (is_target):
			score_change *= QUEST_MULTIPLIER
			is_golden = true
		
		if (is_golden):
			multiplier += 1
			
		stats.completed_words.append(word)
		Game.completed_word.emit(word.word, is_target)
	
	for c in [up, right, down, left]:
		if (c != null):
			c.state.invalid_move = false
	
	up = MoveCandidate.new(current_pos - Corpus.corpus_line_length, Vector2.UP)
	right = MoveCandidate.new(current_pos + 1, Vector2.RIGHT)
	down = MoveCandidate.new(current_pos + Corpus.corpus_line_length, Vector2.DOWN)
	left = MoveCandidate.new(current_pos - 1, Vector2.LEFT)

	return score_change

func _cycle_quest():
	var next_quest: CorpusClass.WordData = null

	var vertical_distance: int
	var horizontal_distance: int

	while (next_quest == null or next_quest.is_completed()):
		vertical_distance = (randi() % 2) + 2
		horizontal_distance = (randi() % 10) + 2
		next_quest = _get_random_word(vertical_distance, horizontal_distance)
	
	current_quest = next_quest.word.to_lower()
	
	_reset_quest_duration(horizontal_distance + (vertical_distance * QUEST_DISTANCE_FACTOR))
	Game.new_quest.emit(current_quest)

func _get_random_word(vertical_distance: int, horizontal_distance: int) -> CorpusClass.WordData:
	var target_pos := current_pos

	# Random quadrant
	match randi() % 4:
		0: # Up and left
			target_pos -= (vertical_distance * Corpus.corpus_line_length)
			target_pos -= horizontal_distance
		1: # Down and left
			target_pos += (vertical_distance * Corpus.corpus_line_length)
			target_pos -= horizontal_distance
		2: # Down and right
			target_pos += (vertical_distance * Corpus.corpus_line_length)
			target_pos += horizontal_distance
		3: # Up and right
			target_pos -= (vertical_distance * Corpus.corpus_line_length)
			target_pos += horizontal_distance

	return Corpus.get_word_of(target_pos)
