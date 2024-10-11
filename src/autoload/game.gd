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
signal new_corpus(corpus: CorpusClass.FullText)
signal new_chapter(chapter: CorpusClass.Chapter)
signal mute_toggled(muted: bool)

const QUEST_MULTIPLIER: int = 4

# How much the distance affects the quest duration
const QUEST_DISTANCE_FACTOR: int = 2

class SaveData:
	var has_completed_a_run: bool
	var color_palette: int
	var corpus_title: String
	var highest_score: StatsSummary
	var most_completed_words: StatsSummary
	var most_completed_quests: StatsSummary
	var most_traversed_characters: StatsSummary

	static func from_dictionary(data: Dictionary) -> SaveData:
		if data == null:
			return SaveData.new()
		var save_data = SaveData.new()
		save_data.has_completed_a_run = data["has_completed_a_run"]
		save_data.color_palette = data["color_palette"]
		save_data.corpus_title = data["corpus_title"]
		save_data.highest_score = StatsSummary.from_dictionary(data["highest_score"])
		save_data.most_completed_words = StatsSummary.from_dictionary(data["most_completed_words"])
		save_data.most_completed_quests = StatsSummary.from_dictionary(data["most_completed_quests"])
		save_data.most_traversed_characters = StatsSummary.from_dictionary(data["most_traversed_characters"])
		return save_data

	func to_dictionary() -> Dictionary:
		return {
			"has_completed_a_run": has_completed_a_run,
			"color_palette": color_palette,
			"corpus_title": corpus_title,
			"highest_score": highest_score.to_dictionary(),
			"most_completed_words": most_completed_words.to_dictionary(),
			"most_completed_quests": most_completed_quests.to_dictionary(),
			"most_traversed_characters": most_traversed_characters.to_dictionary()
		}

	func rank_stats(stats_summary: StatsSummary):
		if stats_summary == null || \
			stats_summary.score == 0 || \
			stats_summary.completed_words == 0 || \
			stats_summary.traversed_characters < 5:
			return

		if (highest_score == null || stats_summary.score > highest_score.score):
			highest_score = stats_summary
		if (most_completed_words == null || stats_summary.completed_words > most_completed_words.completed_words):
			most_completed_words = stats_summary
		if (most_completed_quests == null || stats_summary.completed_quests > most_completed_quests.completed_quests):
			most_completed_quests = stats_summary
		if (most_traversed_characters == null || stats_summary.traversed_characters > most_traversed_characters.traversed_characters):
			most_traversed_characters = stats_summary
	
	func chosen_corpus() -> CorpusClass.FullText:
		match corpus_title:
			PeterPan.title:
				return PeterPan.create_corpus()
			TheWonderfulWizardOfOz.title:
				return TheWonderfulWizardOfOz.create_corpus()
			_:
				return AlicesAdventuresInWonderland.create_corpus()
			
			
class StatsSummary:
	var run_seed: int
	var score: int
	var multiplier: int
	var golden_moves: int
	var vertical_moves: int
	var traversed_characters: int
	var completed_words: int
	var completed_quests: int
	var ratio_of_characters_completed_words: float
	var ratio_of_moves_while_golden: float
	var ratio_of_quests_to_words: float

	static func from_dictionary(data: Dictionary) -> StatsSummary:
		if data == null:
			return null
		var summary = StatsSummary.new()
		summary.run_seed = data["run_seed"]
		summary.score = data["score"]
		summary.multiplier = data["multiplier"]
		summary.golden_moves = data["golden_moves"]
		summary.vertical_moves = data["vertical_moves"]
		summary.traversed_characters = data["traversed_characters"]
		summary.completed_words = data["completed_words"]
		summary.completed_quests = data["completed_quests"]
		summary.ratio_of_characters_completed_words = data["ratio_of_characters_completed_words"]
		summary.ratio_of_moves_while_golden = data["ratio_of_moves_while_golden"]
		summary.ratio_of_quests_to_words = data["ratio_of_quests_to_words"]
		return summary

	func to_dictionary() -> Dictionary:
		return {
			"run_seed": run_seed,
			"score": score,
			"multiplier": multiplier,
			"golden_moves": golden_moves,
			"vertical_moves": vertical_moves,
			"traversed_characters": traversed_characters,
			"completed_words": completed_words,
			"completed_quests": completed_quests,
			"ratio_of_characters_completed_words": ratio_of_characters_completed_words,
			"ratio_of_moves_while_golden": ratio_of_moves_while_golden,
			"ratio_of_quests_to_words": ratio_of_quests_to_words
		}

class Stats:
	var run_seed: int
	var score: int
	var multiplier: int
	var moves_while_golden: int
	var vertical_moves: int
	var traversed_characters: Array[CorpusClass.CharState] = []
	var completed_words: Array[CorpusClass.WordData] = []
	
	func _init(seed_: int):
		run_seed = seed_
		score = 0
		multiplier = 1
		moves_while_golden = 0
	
	func to_summary() -> StatsSummary:
		var summary = StatsSummary.new()
		summary.run_seed = run_seed
		summary.score = score
		summary.multiplier = multiplier
		summary.golden_moves = moves_while_golden
		summary.vertical_moves = vertical_moves
		summary.traversed_characters = traversed_characters.size()
		summary.completed_words = completed_words.size()
		summary.completed_quests = completed_quests().size()
		summary.ratio_of_characters_completed_words = ratio_of_characters_completed_words()
		summary.ratio_of_moves_while_golden = ratio_of_moves_while_golden()
		summary.ratio_of_quests_to_words = ratio_of_quests_to_words()
		return summary

	func completed_quests() -> Array[CorpusClass.WordData]:
		return completed_words.filter(func(w: CorpusClass.WordData): return w.is_quest() and w.is_completed())

	func ratio_of_characters_completed_words() -> float:
		if traversed_characters.size() == 0:
			return 0.0
		var n_completed_chars = completed_words.map(func(w: CorpusClass.WordData): return w.word.length()).reduce(func(a, b): return a + b)
		return n_completed_chars / float(traversed_characters.size())
	
	func ratio_of_moves_while_golden() -> float:
		if (moves_while_golden == 0):
			return 0.0
		return moves_while_golden / float(traversed_characters.size())
	
	func ratio_of_quests_to_words() -> float:
		if (completed_words.size() == 0):
			return 0.0
		var quests = completed_quests()
		return quests.size() / float(completed_words.size())

var stats: Stats
var player_data: SaveData

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
	Game.game_over.connect(_on_game_over)
	player_data = load_data()
	start(player_data.chosen_corpus())


func start(corpus: CorpusClass.FullText, chosen_seed: int = -1):
	is_golden = true
	quest_duration = 0
	if (chosen_seed == -1):
		chosen_seed = randi()
	seed(chosen_seed)
	stats = Stats.new(chosen_seed)

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

func save_data():
	print("Saving data")
	
	if not DirAccess.dir_exists_absolute("user://persist"):
		DirAccess.make_dir_absolute("user://persist")
	var file = FileAccess.open("user://persist/data.json", FileAccess.WRITE)
	
	var data = SaveData.new()
	data.has_completed_a_run = true
	data.color_palette = Refs.current_palette
	data.corpus_title = Corpus.main_corpus.title
	data.rank_stats(stats.to_summary())
	
	var json_data = JSON.stringify(data.to_dictionary())
	file.store_string(json_data)

func load_data() -> SaveData:
	print("Loading data")
	if not FileAccess.file_exists("user://persist/data.json"):
		return SaveData.new()

	var file = FileAccess.open("user://persist/data.json", FileAccess.READ)
	if (file == null):
		return
	
	var json_data = file.get_as_text()
	var json_parser = JSON.new()
	var result = json_parser.parse(json_data)

	if result != OK || !json_parser.data is Dictionary:
		push_error("Failed to parse JSON data: %s in %s at line %s" % [json_parser.get_error_message(), json_data, json_parser.get_error_line()])
		return SaveData.new()

	var data = SaveData.from_dictionary(json_parser.data)

	return data

	var save_data = SaveData.new()
	save_data.has_completed_a_run = data.has_completed_a_run
	save_data.color_palette = data.color_palette
	save_data.corpus_title = data.corpus_title
	save_data.highest_score = data.highest_score
	save_data.most_completed_words = data.most_completed_words
	save_data.most_completed_quests = data.most_completed_quests
	save_data.most_traversed_characters = data.most_traversed_characters

func _on_game_over(_stats: Stats):
	save_data()

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
