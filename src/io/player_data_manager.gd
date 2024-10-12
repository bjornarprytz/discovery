class_name Data


class Save:
	var has_completed_a_run: bool
	var color_palette: int
	var corpus_title: String
	var highest_score: StatsSummary
	var most_completed_words: StatsSummary
	var most_completed_quests: StatsSummary
	var most_traversed_characters: StatsSummary

	static func from_dictionary(data: Dictionary) -> Save:
		if data == null:
			return Save.new()
		var save_data = Save.new()
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

	
static func save_stats(stats: Stats):
	print("Saving data")
	
	if not DirAccess.dir_exists_absolute("user://persist"):
		DirAccess.make_dir_absolute("user://persist")
	var file = FileAccess.open("user://persist/data.json", FileAccess.WRITE)
	
	var data = Data.Save.new()
	data.has_completed_a_run = true
	data.color_palette = Refs.current_palette_idx
	data.corpus_title = Corpus.main_corpus.title
	data.rank_stats(stats.to_summary())
	
	var json_data = JSON.stringify(data.to_dictionary())
	file.store_string(json_data)

static func load_data() -> Data.Save:
	print("Loading data")
	if not FileAccess.file_exists("user://persist/data.json"):
		return Data.Save.new()

	var file = FileAccess.open("user://persist/data.json", FileAccess.READ)
	if (file == null):
		return
	
	var json_data = file.get_as_text()
	var json_parser = JSON.new()
	var result = json_parser.parse(json_data)

	if result != OK || !json_parser.data is Dictionary:
		push_error("Failed to parse JSON data: %s in %s at line %s" % [json_parser.get_error_message(), json_data, json_parser.get_error_line()])
		return Data.Save.new()

	var data = Data.Save.from_dictionary(json_parser.data)

	return data
