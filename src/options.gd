extends Node2D

const SHAKE_MAGNITUDE := 5

@onready var timer: Timer = $Timer
@onready var corpus_input: TextEdit = $CanvasLayer/Background/Corpus/CustomCorpus
@onready var loading: RichTextLabel = $CanvasLayer/Background/Corpus/Loading

@onready var go_time: Control = $CanvasLayer/Background/Corpus/GoTime
@onready var word_count: RichTextLabel = $CanvasLayer/Background/Corpus/GoTime/Words
@onready var length: RichTextLabel = $CanvasLayer/Background/Corpus/GoTime/Length
@onready var go: TextureButton = $CanvasLayer/Background/Corpus/GoTime/Go
@onready var go_boom: CPUParticles2D = $CanvasLayer/Background/Corpus/GoTime/GoBoom
@onready var boom: AudioStreamPlayer2D = $Boom
var sanitize_regex: RegEx

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	corpus_input.text_changed.connect(_load_corpus)
	sanitize_regex = RegEx.new()
	sanitize_regex.compile("\\[.*?\\]")
	corpus_input.grab_focus()
	
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
	
	go_time.visible = true
	
	word_count.text = "Words: " + str(Corpus.words.size() + 1) # +1 because one word is immediately popped by Game
	length.text = "Length: " + str(Corpus.corpus.length())
	
	set_loading(false)

func _input(event: InputEvent) -> void:
	var key = event.as_text()
	
	if (key == "Tab"):
		corpus_input.release_focus()
	
	if (!go_time.visible||key != "Enter"):
		return
	
	if (event.is_pressed()):
		corpus_input.release_focus()
		go.position += Vector2(randf_range( - SHAKE_MAGNITUDE, SHAKE_MAGNITUDE), randf_range( - SHAKE_MAGNITUDE, SHAKE_MAGNITUDE))
	else:
		go.visible = false
		go_boom.position = go.position
		go_boom.emitting = true
		boom.play()
		
		await get_tree().create_timer(go_boom.lifetime).timeout
		
		get_tree().change_scene_to_file("res://main.tscn")

func set_loading(state: bool):
	loading.clear()
	if (state):
		loading.append_text("[wave amp=69].............................................................")
	else:
		loading.append_text(".............................................................")
