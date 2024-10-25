class_name TrophyRoom
extends Node2D

@onready var trophy_text_game: CustomTextGame = %TrophyTextGame
@onready var run_stats_ui: RunStatsUI = %RunStatsUi

var custom_text: String = " home. No place like"
var _easter_egg: Array[String] = ["No", "place", "like", "home"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trophy_text_game.start(CorpusClass.FullText.new("custom", "TrophyRoom", [CorpusClass.Chapter.new(0, "TrophyRoom", custom_text, false)]), false)
	Game.completed_word.connect(_word_complete)

	Audio.cross_fade(Audio.stats_track)

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		if (event.is_action("ui_focus_next")):
			run_stats_ui.cycle_trophy()
		elif (event.is_action("ui_left")):
			run_stats_ui.cycle_corpus(true)
		elif (event.is_action("ui_right")):
			run_stats_ui.cycle_corpus()
		elif (event.is_action("ui_copy")):
			run_stats_ui.copy_seed()
		elif (event.is_action("ui_cancel")):
			_back()
		
		var key = event.as_text()
		trophy_text_game.try_move(key)

func _back():
	get_tree().change_scene_to_packed(preload("res://score.tscn"))

func _easter_egg_check() -> void:
	if _easter_egg.is_empty():
		_make_it_rain()

func _make_it_rain():
	while self != null and !is_queued_for_deletion():
		await get_tree().create_timer(.31).timeout
		for i in range(custom_text.length()):
			var c_state = Corpus.get_state(i)
			if c_state.impassable:
				continue
			c_state.completed_word = true
			c_state.quest = true
			c_state.cursor = false
		trophy_text_game._refresh_text()
		await get_tree().create_timer(.69).timeout

func _word_complete(_w: String, _was_quest: bool):
	_easter_egg.pop_back()
	_easter_egg_check()


func _on_back_pressed() -> void:
	_back()
