extends RichTextLabel
class_name TextSegment

@onready var background: ColorRect = $Background
@onready var ambiance: AudioStreamPlayer2D = $Ambiance

var start_index: int

var dirty: bool = true
var is_offscreen: bool = true

var t: RichTextEffect
const base_volume = -10
const muted_volume = -80

func _ready():
	ambiance.finished.connect(ambiance.play)
	Game.mute_toggled.connect(_on_mute_toggled)
	_on_mute_toggled(Game.is_muted)
	_fade_in_volume()
	Refs.palette_changed.connect(_on_palette_changed)
	_on_palette_changed(Refs.current_palette)

func set_start_index(idx: int) -> void:
	var normalized_idx = Corpus.normalize_idx(idx)
	if start_index == normalized_idx:
		return
	start_index = normalized_idx
	refresh(true)

func contains_idx(idx: int) -> bool:
	var normalized_idx = Corpus.normalize_idx(idx)
	
	for l in range(Corpus.segment_height):
		var line_start_index = Corpus.normalize_idx(start_index + (l * Corpus.corpus_line_length))
		
		if (line_start_index <= normalized_idx and normalized_idx < line_start_index + Corpus.segment_width):
			return true
			
	return false

func _on_palette_changed(palette: Palette):
	if background != null:
		background.color = palette.background_color
	add_theme_color_override("default_color", palette.text_color)
	refresh(true)

func refresh(force: bool = false) -> void:
	if !dirty and !force:
		return

	clear()
	
	if is_offscreen:
		return

	for line in range(Corpus.segment_height):
		_append_line(start_index + (line * Corpus.corpus_line_length))
	
	dirty = false

func _append_line(idx: int) -> void:
	var normalized_idx = Corpus.normalize_idx(idx)

	var current_word: CorpusClass.WordData = Corpus.get_word_of(normalized_idx) as CorpusClass.WordData
	var current_word_is_quest: bool = current_word != null and Game.current_quest.nocasecmp_to(current_word.word) == 0
	
	for pos in range(Corpus.segment_width):
		var char_idx = normalized_idx + pos
		var letter = Corpus.get_char_at(char_idx)
		var char_state = Corpus.get_state(char_idx) as CorpusClass.CharState

		var pushed_effect := false

		if not Validation.is_char_valid(letter):
			current_word = null
			current_word_is_quest = false
		elif current_word == null:
			current_word = Corpus.get_word_of(char_idx) as CorpusClass.WordData
			current_word_is_quest = current_word != null and Game.current_quest.nocasecmp_to(current_word.word) == 0

		var trailing_space: bool = letter == " " and !char_state.cursor and (pos == 0 or pos == Corpus.segment_width - 1)
		if trailing_space:
			# Hack to get around trailing spaces being removed in BBCode
			letter = "_"
			push_color(Color.from_hsv(0, 0, 0, 0))

		var base_color: Color = Refs.current_palette.mark_color
		if (char_state.quest):
			base_color = Refs.current_palette.quest_color
		
		if (char_state.cursor):
			if (letter == " "):
				letter = "_"
			push_customfx(Cursor.new(), {"color": base_color})
			pushed_effect = true
		elif (char_state.impassable and letter != "_"):
			push_color(Refs.current_palette.inert_color)
			pushed_effect = true
		elif (char_state.highlight):
			push_customfx(Highlight.new(), {})
			pushed_effect = true
		elif (char_state.completed_word):
			push_customfx(Quest.new(), {"idx": char_state.local_idx, "len": current_word.word.length(), "color": base_color})
			pushed_effect = true
		elif (char_state.quest):
			push_color(Refs.current_palette.quest_color)
			pushed_effect = true
		elif (char_state.visited and letter != "_"):
			push_color(Refs.current_palette.mark_color)
			pushed_effect = true
		elif (char_state.invalid_move):
			push_customfx(Error.new(), {})
			pushed_effect = true
		elif (current_word_is_quest):
			push_underline()
			pushed_effect = true
		
		append_text(letter)
		
		if pushed_effect:
			pop()
		if trailing_space:
			pop()

func _on_mute_toggled(muted: bool) -> void:
	if muted:
		ambiance.volume_db = muted_volume
	else:
		ambiance.volume_db = base_volume

func _fade_in_volume():
	if Game.is_muted:
		return

	ambiance.volume_db = muted_volume
	var tween = create_tween()

	tween.tween_property(ambiance, "volume_db", base_volume, .69)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	threaded = false
	is_offscreen = false
	refresh()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	threaded = true
	is_offscreen = true
