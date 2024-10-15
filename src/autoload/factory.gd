extends Node2D

var stats_entry_spawner = preload("res://stats_entry_ui.tscn")

func stats_entry(category: String, value: Variant, index: int) -> StatsEntry:
	var entry = stats_entry_spawner.instantiate() as StatsEntry

	var color = Color(0, 0, 0, 1)
	if index % 2 == 0:
		color = Color(1, 1, 1, 1)
	

	entry.initialize(category, value, color)

	return entry
