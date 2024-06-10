class_name LeaderboardEntryUI
extends HBoxContainer

@onready var name_label: RichTextLabel = $Name
@onready var score_label: RichTextLabel = $Score
@onready var rank_label: RichTextLabel = $Rank

const rainbow_tag = "[rainbow freq=.2 sat=0.4]"

func set_entry(entry: SteamLeaderboardManager.LeaderboardEntry, is_current_player: bool=false):
	
	name_label.clear()
	if is_current_player:
		name_label.append_text(rainbow_tag)
	name_label.append_text(entry.name)

	score_label.clear()
	if is_current_player:
		score_label.append_text(rainbow_tag)
	score_label.append_text("[right]%d" % entry.score)
	
	rank_label.clear()

	if is_current_player:
		rank_label.append_text(rainbow_tag)
	rank_label.append_text(str(entry.rank))
