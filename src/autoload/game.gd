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
signal game_over(stats: PlayerData.Stats)
signal new_corpus(corpus: CorpusClass.FullText)
signal new_chapter(chapter: CorpusClass.Chapter)
signal mute_toggled(muted: bool)

const QUEST_MULTIPLIER: int = 4

# How much the distance affects the quest duration
const QUEST_DISTANCE_FACTOR: int = 2

var stats: PlayerData.Stats

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
var score: int:
	get:
		if stats == null:
			return 0
		return stats.score
	set(value):
		if (value == score):
			return
		stats.score = value
var multiplier: int:
	get:
		if stats == null:
			return 1

		return stats.multiplier
	set(value):
		if (value == multiplier):
			return
		stats.multiplier = value
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

func _ready() -> void:
	Game.completed_word.connect(_on_word_complete)
	Game.new_chapter.connect(_on_new_chapter)
	start(PlayerData.player_data.chosen_corpus())


func start(corpus: CorpusClass.FullText, chosen_seed: int = -1):
	is_golden = true
	quest_duration = 0
	if (chosen_seed <= 0):
		chosen_seed = randi()
	seed(chosen_seed)
	Corpus.load_corpus(corpus)
	
	stats = PlayerData.Stats.new(Corpus.corpus, chosen_seed)

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
		Game.game_over.emit(stats)

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

func _reset_word_state():
	var word = Corpus.get_word_of(current_pos) as CorpusClass.WordData
	if (word != null and word.states.all(func(s: CorpusClass.CharState): return s.visited or s.cursor)):
		for s in word.states:
			s.completed_word = false

func _on_word_complete(_word: String, was_quest: bool):
	if (was_quest):
		_cycle_quest()

func _on_new_chapter(chapter: CorpusClass.Chapter):
	if chapter.number not in stats.chapters_visited:
		stats.chapters_visited.append(chapter.number)

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

	while (next_quest == null or next_quest.word.length() <= 1 or next_quest.is_completed()):
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
