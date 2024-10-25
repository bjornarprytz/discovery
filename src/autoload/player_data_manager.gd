extends Node2D

class CorpusTrophies:
	var chapters_visited: Array = []
	var highest_score: StatsSummary = StatsSummary.new()
	var most_completed_words: StatsSummary = StatsSummary.new()
	var most_completed_quests: StatsSummary = StatsSummary.new()
	var most_traversed_characters: StatsSummary = StatsSummary.new()

	static func from_dictionary(data: Dictionary) -> CorpusTrophies:
		if data == null or data.is_empty():
			return CorpusTrophies.new()
		var trophies = CorpusTrophies.new()
		trophies.chapters_visited = [] if "chapters_visited" not in data else data["chapters_visited"]
		trophies.highest_score = StatsSummary.from_dictionary({} if "highest_score" not in data else data["highest_score"])
		trophies.most_completed_words = StatsSummary.from_dictionary({} if "most_completed_words" not in data else data["most_completed_words"])
		trophies.most_completed_quests = StatsSummary.from_dictionary({} if "most_completed_quests" not in data else data["most_completed_quests"])
		trophies.most_traversed_characters = StatsSummary.from_dictionary({} if "most_traversed_characters" not in data else data["most_traversed_characters"])
		return trophies
	
	func rank_stats(stats_summary: StatsSummary):
		if stats_summary == null || \
			stats_summary.score == 0 || \
			stats_summary.completed_words == 0 || \
			stats_summary.traversed_characters < 5:
			return
		
		for chapter in stats_summary.chapters_visited:
			if not chapters_visited.has(chapter):
				chapters_visited.append(chapter)

		if (stats_summary.score >= highest_score.score):
			highest_score = stats_summary
		if (stats_summary.completed_words >= most_completed_words.completed_words):
			most_completed_words = stats_summary
		if (stats_summary.completed_quests >= most_completed_quests.completed_quests):
			most_completed_quests = stats_summary
		if (stats_summary.traversed_characters >= most_traversed_characters.traversed_characters):
			most_traversed_characters = stats_summary


class Save:
	var has_completed_a_run: bool
	var color_palette: int
	var corpus_id: String
	var peter_trophies: CorpusTrophies = CorpusTrophies.new()
	var alice_trophies: CorpusTrophies = CorpusTrophies.new()
	var oz_trophies: CorpusTrophies = CorpusTrophies.new()
	
	static func from_dictionary(data: Dictionary) -> Save:
		if data == null or data.is_empty():
			return Save.new()
		var save_data = Save.new()
		save_data.has_completed_a_run = false if "has_completed_a_run" in data else data["has_completed_a_run"]
		save_data.color_palette = 0 if "color_palette" not in data else data["color_palette"]
		save_data.corpus_id = "" if "corpus_id" not in data else data["corpus_id"]
		save_data.peter_trophies = CorpusTrophies.from_dictionary({} if "peter_trophies" not in data else data["peter_trophies"])
		save_data.alice_trophies = CorpusTrophies.from_dictionary({} if "alice_trophies" not in data else data["alice_trophies"])
		save_data.oz_trophies = CorpusTrophies.from_dictionary({} if "oz_trophies" not in data else data["oz_trophies"])
		
		return save_data

	func rank_stats(stats_summary: StatsSummary):
		if stats_summary == null || \
			stats_summary.score == 0 || \
			stats_summary.completed_words == 0 || \
			stats_summary.traversed_characters < 5:
			return
		
		match stats_summary.corpus_id:
			PeterPan.id:
				peter_trophies.rank_stats(stats_summary)
			TheWonderfulWizardOfOz.id:
				oz_trophies.rank_stats(stats_summary)
			_:
				alice_trophies.rank_stats(stats_summary)
	
	func chosen_corpus() -> CorpusClass.FullText:
		match corpus_id:
			PeterPan.id:
				return PeterPan.create_corpus()
			TheWonderfulWizardOfOz.id:
				return TheWonderfulWizardOfOz.create_corpus()
			_:
				return AlicesAdventuresInWonderland.create_corpus()
			

class Stats:
	var corpus_id: String
	var run_seed: int
	var score: int
	var multiplier: int
	var moves_while_golden: int
	var vertical_moves: int
	var traversed_characters: Array[CorpusClass.CharState] = []
	var completed_words: Array[CorpusClass.WordData] = []
	var chapters_visited: Array = []
	var total_chapters: int
	
	func _init(corpus: CorpusClass.FullText, seed_: int):
		corpus_id = corpus.id
		total_chapters = corpus.chapters.size()
		run_seed = seed_
		score = 0
		multiplier = 1
		moves_while_golden = 0
	
	func to_summary() -> StatsSummary:
		var summary = StatsSummary.new()
		summary.run_seed = run_seed
		summary.corpus_id = corpus_id
		summary.score = score
		summary.multiplier = multiplier
		summary.golden_moves = moves_while_golden
		summary.vertical_moves = vertical_moves
		summary.traversed_characters = traversed_characters.size()
		summary.completed_words = completed_words.size()
		summary.completed_quests = completed_quests().size()
		summary.chapters_visited = chapters_visited
		summary.total_chapters = total_chapters
		summary.ratio_of_characters_completed_words = ratio_of_characters_completed_words()
		summary.ratio_of_moves_while_golden = ratio_of_moves_while_golden()
		summary.ratio_of_quests_to_words = ratio_of_quests_to_words()
		summary.ratio_of_chapters_visited = ratio_of_chapters_visited()

		return summary

	func completed_quests() -> Array[CorpusClass.WordData]:
		if completed_words.is_empty():
			return []

		return completed_words.filter(func(w: CorpusClass.WordData): return w.is_quest() and w.is_completed())

	func ratio_of_characters_completed_words() -> float:
		if traversed_characters.is_empty() || completed_words.is_empty():
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
	
	func ratio_of_chapters_visited() -> float:
		if (total_chapters == 0):
			return 0.0
		
		return chapters_visited.size() / float(total_chapters)

class StatsSummary:
	var run_seed: int
	var corpus_id: String
	var score: int
	var multiplier: int
	var golden_moves: int
	var vertical_moves: int
	var traversed_characters: int
	var completed_words: int
	var completed_quests: int
	var chapters_visited: Array = []
	var total_chapters: int
	var ratio_of_characters_completed_words: float
	var ratio_of_moves_while_golden: float
	var ratio_of_quests_to_words: float
	var ratio_of_chapters_visited: float

	static func from_dictionary(data: Dictionary) -> StatsSummary:
		if data == null or data.is_empty():
			return StatsSummary.new()
		var summary = StatsSummary.new()
		summary.run_seed = 0 if "run_seed" not in data else data["run_seed"]
		summary.corpus_id = AlicesAdventuresInWonderland.id if "corpus_id" not in data else data["corpus_id"]
		summary.score = 0 if "score" not in data else data["score"]
		summary.multiplier = 1 if "multiplier" not in data else data["multiplier"]
		summary.golden_moves = 0 if "golden_moves" not in data else data["golden_moves"]
		summary.vertical_moves = 0 if "vertical_moves" not in data else data["vertical_moves"]
		summary.traversed_characters = 0 if "traversed_characters" not in data else data["traversed_characters"]
		summary.completed_words = 0 if "completed_words" not in data else data["completed_words"]
		summary.completed_quests = 0 if "completed_quests" not in data else data["completed_quests"]
		summary.chapters_visited = [] if "chapters_visited" not in data else data["chapters_visited"]
		summary.total_chapters = 0 if "total_chapters" not in data else data["total_chapters"]
		summary.ratio_of_characters_completed_words = 0.0 if "ratio_of_characters_completed_words" not in data else data["ratio_of_characters_completed_words"]
		summary.ratio_of_moves_while_golden = 0.0 if "ratio_of_moves_while_golden" not in data else data["ratio_of_moves_while_golden"]
		summary.ratio_of_quests_to_words = 0.0 if "ratio_of_quests_to_words" not in data else data["ratio_of_quests_to_words"]
		summary.ratio_of_chapters_visited = 0.0 if "ratio_of_chapters_visited" not in data else data["ratio_of_chapters_visited"]
		return summary


var player_data: Save = Save.new()
var most_recent: StatsSummary = StatsSummary.new()

func _ready():
	player_data = load_data()
	Game.game_over.connect(save_stats)

func save_stats(stats: Stats):
	var summary = stats.to_summary()
	most_recent = summary
	
	if not DirAccess.dir_exists_absolute("user://persist"):
		DirAccess.make_dir_absolute("user://persist")
	var file = FileAccess.open("user://persist/data.json", FileAccess.WRITE)
	
	player_data.has_completed_a_run = true
	player_data.color_palette = Refs.current_palette_idx
	player_data.corpus_id = Corpus.main_corpus.id
	player_data.rank_stats(summary)
	
	var json_data = JSON.stringify(Utils.to_dictionary(player_data))
	file.store_string(json_data)

func load_data() -> Save:
	if not FileAccess.file_exists("user://persist/data.json"):
		return Save.new()

	var file = FileAccess.open("user://persist/data.json", FileAccess.READ)
	if (file == null):
		return Save.new()
	
	var json_data = file.get_as_text()
	var json_parser = JSON.new()
	var result = json_parser.parse(json_data)

	if result != OK || !json_parser.data is Dictionary:
		push_error("Failed to parse JSON data: %s in %s at line %s" % [json_parser.get_error_message(), json_data, json_parser.get_error_line()])
		return Save.new()

	var data = Save.from_dictionary(json_parser.data)

	return data
