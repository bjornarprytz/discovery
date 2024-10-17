class_name TrophyRoom
extends Node2D

@onready var trophy_text_game: CustomTextGame = %TrophyTextGame
@onready var run_stats_ui: RunStatsUI = %RunStatsUi


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trophy_text_game.start(CorpusClass.FullText.new("custom", "TrophyRoom", [CorpusClass.Chapter.new(0, "TrophyRoom", "Alice Peter Oz")]), false)
	Game.completed_word.connect(_word_complete)

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		if (event.is_action("cycle")):
			run_stats_ui.cycle_trophy()
		else:
			var key = event.as_text()
			trophy_text_game.try_move(key)

func _word_complete(w: String, _was_quest: bool):
	if (w.nocasecmp_to("alice") == 0):
		_alice()
	elif (w.nocasecmp_to("peter") == 0):
		_peter()
	elif (w.nocasecmp_to("oz") == 0):
		_oz()


func _alice() -> void:
	run_stats_ui.change_corpus(AlicesAdventuresInWonderland.title)

func _peter() -> void:
	run_stats_ui.change_corpus(PeterPan.title)

func _oz() -> void:
	run_stats_ui.change_corpus(TheWonderfulWizardOfOz.title)
