extends Control

var stats: PlayerData.StatsSummary
@onready var stats_list: VBoxContainer = %StatsList

func _ready() -> void:
	load_stats(PlayerData.StatsSummary.new())
	pass


func load_stats(stats_summary: PlayerData.StatsSummary):
	var key_value_pairs = Utils.to_dictionary(stats_summary)

	for key in key_value_pairs.keys():
		if key_value_pairs[key] is float:
			var entry = Create.stats_entry(key, key_value_pairs[key])
			stats_list.add_child(entry)
		
	pass
