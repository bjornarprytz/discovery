class_name LeaderboardUI
extends ColorRect

@onready var entry_spawner = preload ("res://leaderboard_entry_ui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var leaderboardEntries = await SteamController.get_leaderboard(0, 10)

	var steamUser = SteamController.get_user()

	for entry in leaderboardEntries:
		var entry_label = entry_spawner.instantiate() as LeaderboardEntryUI
		$Margin/VB.add_child(entry_label)
		entry_label.set_entry(entry, steamUser.steam_id == entry.steam_id)
