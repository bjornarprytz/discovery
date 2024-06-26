class_name LeaderboardUI
extends ColorRect

@onready var entry_spawner = preload ("res://leaderboard_entry_ui.tscn")

@onready var scope_button_label: RichTextLabel = $VB/Buttons/ScopeButton/Label
@onready var toggle_show_button: Button = $VB/Buttons/ToggleShowButton
@onready var entries_container: Node = $VB/Margin/VB/Entries
@onready var trophy_icon : TextureRect = $VB/Buttons/ToggleShowButton/Trophy

@onready var is_hidden: bool = true

var scopes: Array[Steam.LeaderboardDataRequest] = [
	Steam.LEADERBOARD_DATA_REQUEST_FRIENDS,
	Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER,
	Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
]

var current_scope_index: int = 0:
	set(value):
		current_scope_index = value % scopes.size()
var current_scope: Steam.LeaderboardDataRequest:
	get:
		return scopes[current_scope_index]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_fetch_leaderboard()

func _on_scope_button_pressed() -> void:
	current_scope_index += 1
	
	scope_button_label.clear()
	scope_button_label.append_text("[center]")

	if current_scope == Steam.LEADERBOARD_DATA_REQUEST_FRIENDS:
		scope_button_label.append_text("[u]Friends[/u]")
	else:
		scope_button_label.append_text("Friends")

	scope_button_label.append_text(" / ")

	if current_scope == Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER:
		scope_button_label.append_text("[u]Proximity[/u]")
	else:
		scope_button_label.append_text("Proximity")
	
	scope_button_label.append_text(" / ")

	if current_scope == Steam.LEADERBOARD_DATA_REQUEST_GLOBAL:
		scope_button_label.append_text("[u]Top[/u]")
	else:
		scope_button_label.append_text("Top")
	
	_fetch_leaderboard()

func _fetch_leaderboard() -> void:
	var leaderboardEntries = await SteamController.get_leaderboard(0, 10, current_scope)

	var steamUser = SteamController.get_user()

	for existingEntry in entries_container.get_children():
		existingEntry.queue_free()
	
	for entry in leaderboardEntries:
		var entry_label = entry_spawner.instantiate() as LeaderboardEntryUI
		entries_container.add_child(entry_label)
		entry_label.set_entry(entry, steamUser.steam_id == entry.steam_id)

func _on_toggle_show_button_pressed() -> void:
	trophy_icon.hide()
	is_hidden = !is_hidden

	var translation: float
	var toggle_button_text: String

	if is_hidden:
		translation = size.x
		toggle_button_text = " < "
	else:
		translation = -size.x
		toggle_button_text = " > "

	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + translation, .3)

	toggle_show_button.text = toggle_button_text
