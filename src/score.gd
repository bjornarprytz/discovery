extends Node2D

@onready var menu: CustomTextGame = $Background/ScoreTextGame

@onready var score: RichTextLabel = $Background/HB/GameOver/Score
@onready var stats: StatsList = %Stats
@onready var highscore: RichTextLabel = $Background/HB/GameOver/Highscore
@onready var stats_container: MarginContainer = %StatsContainer

@onready var all_container: HBoxContainer = $Background/HB
@onready var base_container_width = all_container.size.x
@onready var corpus_select: OptionButton = %CorpusSelect
@onready var seed_input: LineEdit = %SeedInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.start(CorpusClass.FullText.new("custom", "ScoreScreen", [CorpusClass.Chapter.new(0, "ScoreScreen", "Retry Quit Secret Trophy")]), false)
	
	var current_highscore = _load_highscore()
	
	_update_score()
	
	highscore.clear()
	
	if (current_highscore < Game.score):
		highscore.append_text("[right][wave]New highscore!")
		_save_highscore(Game.score)
	else:
		highscore.append_text("[right][color=gray]Best: " + str(current_highscore).pad_zeros(5))
	
	Game.completed_word.connect(_word_complete)
	
	Audio.cross_fade(Audio.score_track)
	match Corpus.main_corpus.id:
		PeterPan.id:
			corpus_select.selected = 1
		TheWonderfulWizardOfOz.id:
			corpus_select.selected = 2
		_:
			corpus_select.selected = 0
	
	stats.load_stats(PlayerData.most_recent)

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		var key = event.as_text()
		menu.try_move(key)

func _word_complete(w: String, _was_quest: bool):
	if (w.nocasecmp_to("quit") == 0):
		_quit()
	elif (w.nocasecmp_to("retry") == 0):
		_retry()
	elif (w.nocasecmp_to("secret") == 0):
		_settings()
	elif (w.nocasecmp_to("trophy") == 0):
		_stats()

func _load_highscore() -> int:
	var file = FileAccess.open("user://highscore.txt", FileAccess.READ)
	if (file == null):
		return 0
	
	var highscore_value = file.get_64()
	
	if (highscore_value == null):
		return 0
	
	return highscore_value

func _save_highscore(score_value: int):
	var save = FileAccess.open("user://highscore.txt", FileAccess.WRITE)
	save.store_64(score_value)
	save.close()

func _retry():
	var chosen_seed: int = -1
	if seed_input.text.length() == 10:
		chosen_seed = int(seed_input.text)
	
	Game.start(Corpus.main_corpus, chosen_seed)
	get_tree().change_scene_to_file("res://main.tscn")

func _update_score(underscore: bool = false):
	score.clear()
	if underscore:
		score.append_text("[center][u][rainbow freq=.2 sat=0.4]" + str(Game.score).pad_zeros(5))
	else:
		score.append_text("[center][rainbow freq=.2 sat=0.4]" + str(Game.score).pad_zeros(5))


func _settings():
	get_tree().change_scene_to_file("res://options.tscn")

func _stats():
	get_tree().change_scene_to_file("res://trophy_room.tscn")

func _quit():
	get_tree().quit()

func _on_retry_pressed() -> void:
	_retry()

func _on_settings_pressed() -> void:
	_settings()

func _on_quit_pressed() -> void:
	_quit()

func _on_stats_pressed() -> void:
	_stats()

func _on_corpus_select_item_selected(index: int) -> void:
	match index:
		0:
			Corpus.load_corpus(AlicesAdventuresInWonderland.create_corpus())
		1:
			Corpus.load_corpus(PeterPan.create_corpus())
		2:
			Corpus.load_corpus(TheWonderfulWizardOfOz.create_corpus())

func _open_stats():
	stats_container.show()
	stats.load_stats(PlayerData.most_recent)

func _close_stats():
	stats_container.hide()

func _on_stats_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			_close_stats()

func _on_close_stats_pressed() -> void:
	_close_stats()

func _on_score_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			_open_stats()

func _on_score_mouse_entered() -> void:
	_update_score(true)

func _on_score_mouse_exited() -> void:
	_update_score()

func _on_game_over_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_close_stats()
