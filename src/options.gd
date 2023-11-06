extends Node2D

const SHAKE_MAGNITUDE := 5

@onready var timer : Timer = $Timer
@onready var corpus_input : TextEdit = $GameOver/CustomCorpus
var sanitize_regex : RegEx

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	corpus_input.text_changed.connect(_load_corpus)
	sanitize_regex = RegEx.new()
	sanitize_regex.compile("\\[.*?\\]")
	$GameOver/CustomCorpus.grab_focus()
	
func _load_corpus():
	if (!timer.is_stopped()):
		timer.start(2)
		return
	
	set_loading(true)
	timer.start(2)
	await timer.timeout
	timer.stop()
	var text_without_tags = sanitize_regex.sub(corpus_input.text, "", true)
	
	Game.start(text_without_tags)
	
	$GameOver/GoTime.visible = true
	
	$GameOver/GoTime/Words.text = "Words: " + str(Corpus.words.size() + 1) # +1 because one word is immediately popped by Game	
	$GameOver/GoTime/Length.text = "Length: " + str(Corpus.corpus.length())
	
	set_loading(false)

func _input(event: InputEvent) -> void:
	var key = event.as_text()
	
	if (key == "Tab"):
		$GameOver/CustomCorpus.release_focus()
	
	if (!$GameOver/GoTime.visible || key != "Enter"):
		return
	
	if (event.is_pressed()):
		$GameOver/CustomCorpus.release_focus() 
		$GameOver/GoTime/Go.position += Vector2(randf_range(-SHAKE_MAGNITUDE, SHAKE_MAGNITUDE), randf_range(-SHAKE_MAGNITUDE, SHAKE_MAGNITUDE))
	else:
		$GameOver/GoTime/Go.visible = false
		var particles : CPUParticles2D = $GameOver/GoTime/GoBoom
		particles.position = $GameOver/GoTime/Go.position
		particles.emitting = true
		
		await get_tree().create_timer(particles.lifetime).timeout
		
		get_tree().change_scene_to_file("res://main.tscn")


func set_loading(state: bool):
	$GameOver/Loading.clear()
	if (state):
		$GameOver/Loading.append_text("[wave amp=69].............................................................")
	else:
		$GameOver/Loading.append_text(".............................................................")
