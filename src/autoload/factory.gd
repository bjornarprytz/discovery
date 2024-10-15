extends Node2D

var stats_entry_spawner = preload("res://stats_entry_ui.tscn")

func stats_entry(category: String, value: float) -> StatsEntry:
	var entry = stats_entry_spawner.instantiate() as StatsEntry

	entry.initialize(category, value)

	return entry
