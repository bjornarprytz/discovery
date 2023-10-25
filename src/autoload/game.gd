extends Node2D
class_name GameClass


signal moved(step: Vector2, score_change: int)
signal completed_quest(word: String)
signal new_target(word: String)
signal game_over

const ERROR_COLOR: Color = Color.CRIMSON
const MARK_COLOR: Color = Color.AQUAMARINE
const QUEST_COLOR: Color = Color.GOLDENROD
const IMPASSABLE_COLOR: Color = Color.LIGHT_GRAY

const QUEST_MULTIPLIER: int = 4
const FATIGUE_FACTOR: int = 5

var current_target : String
var score := 0
var multiplier := 1

func cycle_target():
	current_target = Corpus.words.pop_front()
	new_target.emit(current_target)

func _ready() -> void:
	Corpus.load_corpus()
	completed_quest.connect(_on_quest_complete)

func _on_quest_complete(word: String):
	cycle_target()
