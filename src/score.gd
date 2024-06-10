extends Node2D

@onready var menu: ScoreTextGame = $ScoreTextGame

@onready var leaderboard: LeaderboardUI = $Leaderboard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScoreTextGame.start("Retry Quit Corpus", false)
	
	var current_highscore = _load_highscore()
	
	$GameOver/Score.clear()
	$GameOver/Score.append_text("[center][rainbow freq=.2 sat=0.4]" + str(Game.score).pad_zeros(5))
	
	$GameOver/Highscore.clear()
	
	if (current_highscore < Game.score):
		$GameOver/Highscore.append_text("[right][wave]New highscore!")
		_save_highscore(Game.score)
	else:
		$GameOver/Highscore.append_text("[right][color=gray]Best: " + str(current_highscore).pad_zeros(5))
	
	Game.completed_word.connect(_word_complete)

	if SteamController == null:
		leaderboard.queue_free()
	else:
		leaderboard.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		var key = event.as_text()
		if (!menu.try_move(key)):
			$Denied.play()

func _word_complete(w: String, _was_quest: bool):
	if (w.nocasecmp_to("quit") == 0):
		_quit()
	elif (w.nocasecmp_to("retry") == 0):
		_retry()
	elif (w.nocasecmp_to("corpus") == 0):
		_settings()

func _load_highscore() -> int:
	var file = FileAccess.open("user://highscore.txt", FileAccess.READ)
	if (file == null):
		return 0
	
	var highscore = file.get_64()
	
	if (highscore == null):
		return 0
	
	return highscore

func _save_highscore(score: int):
	var save = FileAccess.open("user://highscore.txt", FileAccess.WRITE)
	save.store_64(score)
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
