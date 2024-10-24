class_name StatsList
extends VBoxContainer

@onready var stats_list: VBoxContainer = %StatsList
@onready var seed_button: Button = %SeedButton

var current_stats: PlayerData.StatsSummary

func load_stats(stats_summary: PlayerData.StatsSummary):
	current_stats = stats_summary
	seed_button.text = "Seed: %s" % [str(stats_summary.run_seed) if stats_summary.run_seed != 0 else "-"]
	
	var entries = {
		"Score": [stats_summary.score, "score"],
		"Multiplier": [stats_summary.multiplier, "multiplier"],
		"Total Moves": [stats_summary.traversed_characters, "traversed_characters"],
		"Vertical Moves": [stats_summary.vertical_moves, "vertical_moves"],
		"Golden Moves": [stats_summary.golden_moves, "golden_moves"],
		"Completed Words": [stats_summary.completed_words, "completed_words"],
		"Completed Quests": [stats_summary.completed_quests, "completed_quests"],
		"Chapters Visited": ["%d / %d" % [stats_summary.chapters_visited.size(), stats_summary.total_chapters], "chapters_visited"],
		"Ratio of Characters to Completed Words": ["%.2f" % stats_summary.ratio_of_characters_completed_words, "ratio_of_characters_completed_words"],
		"Ratio of Moves While Golden": ["%.2f" % stats_summary.ratio_of_moves_while_golden, "ratio_of_moves_while_golden"],
		"Ratio of Quests to Words": ["%.2f" % stats_summary.ratio_of_quests_to_words, "ratio_of_quests_to_words"],
	}

	var i = 0
	for key in entries.keys():
		var data = entries[key]
		var value = data[0]
		var data_key = data[1]
		
		var entry: StatsEntry
		if stats_list.get_child_count() <= i:
			entry = Create.stats_entry(key, value, i)
			stats_list.add_child(entry)
		else:
			entry = stats_list.get_child(i)
			entry.initialize(key, value, i)
		
		var is_new_best = true
		for trophy in ["highest_score", "most_completed_words", "most_completed_quests", "most_traversed_characters"]:
			for corpus in ["alice_trophies", "peter_trophies", "oz_trophies"]:
				var stats = PlayerData.player_data.get(corpus).get(trophy) as PlayerData.StatsSummary
				
				if data_key == "chapters_visited":
					if stats.corpus_id != stats_summary.corpus_id:
						continue
					if stats.chapters_visited.size() < stats_summary.chapters_visited.size():
						is_new_best = false
						break
				elif value is String:
					if stats.get(data_key) > float(value):
						is_new_best = false
						break
				elif stats.get(data_key) > value:
					is_new_best = false
					break
		
		if is_new_best:
			entry.highlight()
		else:
			entry.unhighlight()
		
		Utils.fade_in(entry, 0.5)
		await get_tree().create_timer(0.069).timeout
		i += 1
func copy_seed():
	DisplayServer.clipboard_set(str(current_stats.run_seed))

func _on_seed_button_pressed() -> void:
	copy_seed()
