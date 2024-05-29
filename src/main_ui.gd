class_name DiscoveryUI
extends CanvasLayer

@onready var ui: ColorRect = $Border
@onready var score_board: RichTextLabel = $Border/QuestBar/Score
@onready var target_ui: RichTextLabel = $Border/QuestBar/TargetWord
@onready var quest_duration_label: RichTextLabel = $Border/QuestBar/QuestDuration
@onready var next_quest_duration_label: RichTextLabel = $Border/QuestBar/QuestDuration/NextValue
@onready var quest_bar: ProgressBar = $Border/QuestBar
@onready var sheen: ColorRect = $Border/QuestBar/TargetWord/Sheen
@onready var sheen_base_position = sheen.position

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

	var sheen_tween = create_tween().set_ease(Tween.EASE_IN)
	sheen_tween.tween_property(sheen, 'position:x', 545.0, 2.0)
	await sheen_tween.finished
	sheen.position = sheen_base_position

func _update_score():
	score_board.clear()
	score_board.append_text("[right]" + str(Game.score).pad_zeros(5))
