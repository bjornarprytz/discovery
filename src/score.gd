extends Node2D

@onready var menu: ScoreTextGame = $Background/ScoreTextGame

@onready var leaderboard: LeaderboardUI = $Background/HB/Leaderboard

@onready var score: RichTextLabel = $Background/HB/GameOver/Score
@onready var highscore: RichTextLabel = $Background/HB/GameOver/Highscore

@onready var all_container: HBoxContainer = $Background/HB
@onready var base_container_width = all_container.size.x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.start("Retry Quit Secret", false)
	
	var current_highscore = _load_highscore()
	
	score.clear()
	score.append_text("[center][rainbow freq=.2 sat=0.4]" + str(Game.score).pad_zeros(5))
	
	highscore.clear()
	
	if (current_highscore < Game.score):
		highscore.append_text("[right][wave]New highscore!")
		_save_highscore(Game.score)
	else:
		highscore.append_text("[right][color=gray]Best: " + str(current_highscore).pad_zeros(5))
	
	Game.completed_word.connect(_word_complete)

	if SteamController.is_initialized():
		leaderboard.show()
		highscore.hide()
	else:
		leaderboard.queue_free()
		all_container.size.x = get_viewport_rect().size.x
	
	Audio.play_score()

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
	Game.start()
	get_tree().change_scene_to_file("res://main.tscn")

func _settings():
	get_tree().change_scene_to_file("res://options.tscn")

func _quit():
	get_tree().quit()

func _on_retry_pressed() -> void:
	_retry()

func _on_settings_pressed() -> void:
	_settings()

func _on_quit_pressed() -> void:
	_quit()


func _on_leaderboard_toggle_show(show_leaderboard: bool) -> void:
	
	var target_width: float
	if show_leaderboard:
		target_width = base_container_width -leaderboard.size.x
	else:
		target_width = base_container_width
	
	var tween = create_tween()
	tween.tween_property(all_container, "size:x", target_width, .3)
