class_name CorpusUI
extends Control

@onready var timer: Timer = $Timer
@onready var corpus_input: TextEdit = $CustomCorpus
@onready var loading: RichTextLabel = $Loading

@onready var go_time: Control = $GoTime
@onready var word_count: RichTextLabel = $GoTime/Words
@onready var length: RichTextLabel = $GoTime/Length
@onready var go: TextureButton = $GoTime/Go
@onready var go_boom: CPUParticles2D = $GoTime/GoBoom
@onready var boom: AudioStreamPlayer2D = $Boom

@onready var alice_button: Button = $PanelContainer/VBoxContainer/AliceButton
@onready var peter_pan_button: Button = $PanelContainer/VBoxContainer/PeterPanButton
@onready var oz_button: Button = $PanelContainer/VBoxContainer/OzButton

const SEGMENT_COUNT := 9
const SHAKE_MAGNITUDE := 5
@onready var minimum_corpus_length := ceil((Corpus.segment_height * Corpus.segment_width * SEGMENT_COUNT) / 1000.0) * 1000.0
@onready var minimum_word_count := minimum_corpus_length / 20

var sanitize_regex: RegEx
var _valid_corpus = false

func _ready() -> void:
	corpus_input.text_changed.connect(_load_corpus)
	sanitize_regex = RegEx.new()
	sanitize_regex.compile("\\[.*?\\]")
	corpus_input.grab_focus()
	_update_button_state()

func _update_button_state():
	alice_button.text = AlicesAdventuresInWonderland.title
	peter_pan_button.text = PeterPan.title
	oz_button.text = TheWonderfulWizardOfOz.title
	
	match Corpus.main_corpus.id:
		AlicesAdventuresInWonderland.id:
			alice_button.button_pressed = true
			alice_button.text = "* %s *" % alice_button.text
		PeterPan.id:
			peter_pan_button.button_pressed = true
			peter_pan_button.text = "* %s *" % peter_pan_button.text
		TheWonderfulWizardOfOz.id:
			oz_button.button_pressed = true
			oz_button.text = "* %s *" % oz_button.text
		
	
func _load_corpus():
	if (!timer.is_stopped()):
		timer.start(2)
		return
	
	set_loading(true)
	timer.start(2)
	await timer.timeout
	timer.stop()
	var text_without_tags = sanitize_regex.sub(corpus_input.text, "", true)
	
	Game.start(CorpusClass.FullText.new("custom", "CustomCorpus", [CorpusClass.Chapter.new(0, "CustomCorpus", text_without_tags)]))
	
	go_time.visible = true
	_valid_corpus = true

	word_count.text = "Words: " + str(Corpus.get_words().size())
	length.text = "Length: " + str(Corpus.corpus.length())

	if Corpus.get_words().size() < minimum_word_count:
		word_count.text += "/ %d" % minimum_word_count
		_valid_corpus = false
		
	if Corpus.corpus.length() < minimum_corpus_length:
		length.text += "/ %d" % minimum_corpus_length
		_valid_corpus = false
	
	set_loading(false)

func _input(event: InputEvent) -> void:
	var key = event.as_text()
	
	if (key == "Tab"):
		corpus_input.release_focus()
	
	if (!_valid_corpus || !go_time.visible || key != "Enter"):
		return
	
	if (event.is_pressed()):
		corpus_input.release_focus()
		go.position += Vector2(randf_range(-SHAKE_MAGNITUDE, SHAKE_MAGNITUDE), randf_range(-SHAKE_MAGNITUDE, SHAKE_MAGNITUDE))
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


func _on_alice_button_pressed() -> void:
	Corpus.load_corpus(AlicesAdventuresInWonderland.create_corpus(), true)
	_update_button_state()

func _on_peter_pan_button_pressed() -> void:
	Corpus.load_corpus(PeterPan.create_corpus(), true)
	_update_button_state()

func _on_oz_button_pressed() -> void:
	Corpus.load_corpus(TheWonderfulWizardOfOz.create_corpus(), true)
	_update_button_state()
