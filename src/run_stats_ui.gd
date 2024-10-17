class_name RunStatsUI
extends Control

var stats: PlayerData.StatsSummary

@onready var stats_list: VBoxContainer = %StatsList
@onready var header: RichTextLabel = %Header
@onready var prev_corpus_button: Button = %PrevCorpusButton
@onready var next_corpus_button: Button = %NextCorpusButton
@onready var seed_button: Button = %SeedButton

# Names here are important to match trophy titles
@onready var highest_score: Button = %HighestScore
@onready var most_completed_words: Button = %MostWords
@onready var most_completed_quests: Button = %MostQuests
@onready var most_traversed_characters: Button = %MostMoves


var corpus_titles = [
	PeterPan.title, # prev
	AlicesAdventuresInWonderland.title, # current
	TheWonderfulWizardOfOz.title # next
]

var current_trophy_index: int
var trophy_titles = [
	"highest_score",
	"most_completed_words",
	"most_completed_quests",
	"most_traversed_characters"
]

var current_stats: PlayerData.StatsSummary

func _ready() -> void:
	change_corpus(AlicesAdventuresInWonderland.title)
	pass

func load_stats(stats_summary: PlayerData.StatsSummary):
	current_stats = stats_summary
	prev_corpus_button.text = "<%s" % corpus_titles[0]
	header.text = corpus_titles[1]
	next_corpus_button.text = "%s>" % corpus_titles[2]
	seed_button.text = "Seed: %d" % stats_summary.run_seed

	var entries = {
		"Score": stats_summary.score,
		"Multiplier": stats_summary.multiplier,
		"Total Moves": stats_summary.traversed_characters,
		"Vertical Moves": stats_summary.vertical_moves,
		"Golden Moves": stats_summary.golden_moves,
		"Completed Words": stats_summary.completed_words,
		"Completed Quests": stats_summary.completed_quests,
		"Chapters Visited": "%d / %d" % [stats_summary.chapters_visited.size(), stats_summary.total_chapters],
		"Ratio of Characters to Completed Words": "%.2f" % stats_summary.ratio_of_characters_completed_words,
		"Ratio of Moves While Golden": "%.2f" % stats_summary.ratio_of_moves_while_golden,
		"Ratio of Quests to Words": "%.2f" % stats_summary.ratio_of_quests_to_words,
		"Ratio of Chapters Visited": "%.2f" % stats_summary.ratio_of_chapters_visited
	}

	var i = 0
	for key in entries.keys():
		var value = entries[key]
		
		var entry: StatsEntry
		if stats_list.get_child_count() <= i:
			entry = Create.stats_entry(key, value, i)
			stats_list.add_child(entry)
		else:
			entry = stats_list.get_child(i)
			entry.initialize(key, value, i)
		
		Utils.fade_in(entry, 0.5)
		await get_tree().create_timer(0.069).timeout
		i += 1

func load_corpus_stats(trophy: String = "highest_score"):
	var trophies: PlayerData.CorpusTrophies
	var next_trophy_index = trophy_titles.find(trophy)

	if next_trophy_index == -1:
		push_error("Trophy %s not found" % trophy)
		return

	match corpus_titles[1]:
		PeterPan.title:
			trophies = PlayerData.player_data.peter_trophies
		TheWonderfulWizardOfOz.title:
			trophies = PlayerData.player_data.oz_trophies
		_:
			trophies = PlayerData.player_data.alice_trophies

	(get(trophy) as Button).button_pressed = true
	load_stats(trophies.get(trophy))
	current_trophy_index = next_trophy_index

func change_corpus(title: String):
	match title:
		PeterPan.title:
			corpus_titles = [
				TheWonderfulWizardOfOz.title, # next
				PeterPan.title, # current
				AlicesAdventuresInWonderland.title # prev
			]
		TheWonderfulWizardOfOz.title:
			corpus_titles = [
				AlicesAdventuresInWonderland.title, # next
				TheWonderfulWizardOfOz.title, # current
				PeterPan.title # prev
			]
		AlicesAdventuresInWonderland.title:
			corpus_titles = [
				PeterPan.title, # next
				AlicesAdventuresInWonderland.title, # current
				TheWonderfulWizardOfOz.title # prev
			]
	load_corpus_stats()

func cycle_trophy():
	current_trophy_index = (current_trophy_index + 1) % trophy_titles.size()
	load_corpus_stats(trophy_titles[current_trophy_index])

func _on_highest_score_pressed() -> void:
	load_corpus_stats("highest_score")

func _on_most_words_pressed() -> void:
	load_corpus_stats("most_completed_words")

func _on_most_quests_pressed() -> void:
	load_corpus_stats("most_completed_quests")

func _on_most_moves_pressed() -> void:
	load_corpus_stats("most_traversed_characters")

func _on_prev_corpus_button_pressed() -> void:
	corpus_titles.push_front(corpus_titles.pop_back())
	load_corpus_stats()
	
func _on_next_corpus_button_pressed() -> void:
	corpus_titles.push_back(corpus_titles.pop_front())
	load_corpus_stats()

func _on_seed_button_pressed() -> void:
	DisplayServer.clipboard_set(str(current_stats.run_seed))
