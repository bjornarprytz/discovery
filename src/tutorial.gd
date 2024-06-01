class_name TutorialUI
extends Panel

@onready var label : RichTextLabel = $Text

var _highlighted_moves: Array[GameClass.MoveCandidate] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Use your keyboard to navigate. Available moves:"
	
	var i = 0
	for move in [Game.up, Game.right, Game.down, Game.left]:
		if move.state.impassable:
			continue
		if i > 0:
			label.append_text(", ")
		move.state.highlight = true
		_highlighted_moves.push_back(move)
		label.push_bgcolor(Game.QUEST_COLOR)
		label.append_text(move.character.to_upper())
		label.pop()
		i += 1

func stop() -> void:
	for move in _highlighted_moves:
		move.state.highlight = false
	
	queue_free()
