extends Node2D

@onready var menu : ScoreTextGame = $ScoreTextGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GameOver/Score.clear()
	$GameOver/Score.append_text("[center][rainbow freq=.2 sat=0.4]" + str(Game.score).pad_zeros(5))
	
	Game.completed_quest.connect(_word_complete)

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		var key = event.as_text()
		if (!menu.try_move(key)):
			$Denied.play()

func _word_complete(w : String):
	if (w.nocasecmp_to("quit") == 0):
		get_tree().quit()
	elif(w.nocasecmp_to("restart") == 0):
		get_tree().change_scene_to_file("res://main.tscn")
