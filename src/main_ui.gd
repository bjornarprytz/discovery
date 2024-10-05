class_name DiscoveryUI
extends CanvasLayer

@onready var ui: ColorRect = $Border
@onready var menu: ColorRect = $Menu
@onready var mute_off: Button = $Menu/MuteOff
@onready var mute_on: Button = $Menu/MuteOn
@onready var chapter_title: RichTextLabel = $Menu/ChapterTitle
@onready var score_board: RichTextLabel = $Border/QuestBar/Score
@onready var target_ui: RichTextLabel = $Border/QuestBar/TargetWord
@onready var quest_duration_label: RichTextLabel = $Border/QuestBar/QuestDuration
@onready var next_quest_duration_label: RichTextLabel = $Border/QuestBar/QuestDuration/NextValue
@onready var multiplier_label: RichTextLabel = $Border/QuestBar/Multiplier
@onready var quest_bar: ProgressBar = $Border/QuestBar
@onready var sheen: ColorRect = $Border/QuestBar/TargetWord/Sheen
@onready var sheen_base_position = sheen.position

func _ready() -> void:
	_set_score(Game.score)
	_on_quest_duration_tick(Game.quest_duration, Game.quest_duration)
	Game.quest_duration_tick.connect(_on_quest_duration_tick)
	_on_new_target(Game.current_quest)
	Game.new_quest.connect(_on_new_target)
	Game.golden_changed.connect(_on_golden_changed)
	Game.multiplier_changed.connect(_on_multiplier_changed)
	Game.moved.connect(_on_moved)
	Game.new_chapter.connect(_on_new_chapter)
	Game.mute_toggled.connect(_on_mute_toggled)
	_on_mute_toggled(Game.is_muted)

func set_show_menu(show_ui: bool) -> void:
	var toggle_tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	if (show_ui):
		menu.modulate.a = 0.0
		menu.show()
		toggle_tween.tween_property(ui, 'position:y', 648, .3)
		toggle_tween.tween_property(menu, 'modulate:a', 1.0, .3)
	else:
		toggle_tween.tween_property(ui, 'position:y', 588, .3)
		toggle_tween.tween_property(menu, 'modulate:a', 0.0, .3)
		await toggle_tween.finished
		menu.hide()

func _on_new_chapter(chapter: CorpusClass.Chapter):
	chapter_title.clear()
	chapter_title.append_text("[center]")
	chapter_title.push_color(Color.BLACK)
	chapter_title.append_text(chapter.title)

func _on_quest_duration_tick(duration: int, cap: int):
	next_quest_duration_label.clear()
	next_quest_duration_label.append_text(str(duration))
	var quest_progress: float = (float(duration) / float(cap)) * 100.0
	var tween = create_tween().set_parallel()
	tween.tween_property(quest_bar, 'value', quest_progress, .2)
	tween.tween_property(quest_duration_label, 'position:y', quest_duration_label.position.y + quest_duration_label.size.y, .4)
	await tween.finished
	quest_duration_label.clear()
	quest_duration_label.append_text(str(duration))
	quest_duration_label.position.y = 0

func _on_new_target(word: String):
	target_ui.clear()
	target_ui.append_text("[center]>" + word + "<")

	var sheen_tween = create_tween()
	sheen_tween.tween_property(sheen, 'position:x', target_ui.size.x + 50.0, 2.0)
	await sheen_tween.finished
	sheen.position = sheen_base_position

func _on_moved(_prev_pos: int, _current_pos: int, _direction: Vector2, score_change: int):
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_method(_set_score, Game.score - score_change, Game.score, .69)

func _set_score(score: int):
	score_board.clear()
	score_board.append_text("[right]" + str(score).pad_zeros(5))

func _on_golden_changed(is_golden: bool):
	var ui_color: Color

	if (is_golden):
		ui_color = Refs.quest_color
	else:
		ui_color = Refs.inert_color

	ui.color = ui_color
	multiplier_label.self_modulate = ui_color

func _on_multiplier_changed(multiplier: int):
	multiplier_label.clear()
	multiplier_label.append_text("[right]x%d" % multiplier)

func _on_mute_toggled(muted: bool):
	mute_off.visible = !muted
	mute_on.visible = muted

func _on_mute_off_pressed() -> void:
	Game.is_muted = true

func _on_mute_on_pressed() -> void:
	Game.is_muted = false
