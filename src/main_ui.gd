class_name DiscoveryUI
extends CanvasLayer

@onready var ui: ColorRect = $Border
@onready var score_board: RichTextLabel = $Border/QuestBar/Score
@onready var target_ui: RichTextLabel = $Border/QuestBar/TargetWord
@onready var quest_duration_label: RichTextLabel = $Border/QuestBar/QuestDuration
@onready var quest_bar: ProgressBar = $Border/QuestBar

func _ready() -> void:
	_on_quest_duration_tick(Game.quest_duration, Game.quest_duration)
	Game.quest_duration_tick.connect(_on_quest_duration_tick)
	_on_new_target(Game.current_target)
	Game.new_target.connect(_on_new_target)
	_update_score()

func update_score():
	_update_score()

func set_show(show_ui: bool) -> void:
	var toggle_tween = create_tween().set_ease(Tween.EASE_IN)
	if (show_ui):
		toggle_tween.tween_property(ui, 'position:y', 588, .5)
	else:
		toggle_tween.tween_property(ui, 'position:y', 648, .5)

func _on_quest_duration_tick(duration: int, cap: int):
	quest_duration_label.clear()
	quest_duration_label.append_text(str(duration))
	var next_value: float = (float(duration) / float(cap)) * 100.0
	var tween = create_tween()
	tween.tween_property(quest_bar, 'value', next_value, .2)

func _on_new_target(word: String):
	target_ui.clear()
	target_ui.append_text("[center]>" + word + "<")

func _update_score():
	score_board.clear()
	score_board.append_text("[right]" + str(Game.score).pad_zeros(5))
