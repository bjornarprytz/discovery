class_name TutorialUI
extends Panel

@onready var label: RichTextLabel = $Text

var _highlighted_moves: Array[GameClass.MoveCandidate] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Use your keyboard to navigate. Available moves: "
	
	var valid_candidates = {}
	for move in [Game.up, Game.right, Game.down, Game.left]:
		if move.state.impassable:
			continue
		
		var character = move.character.to_lower()

		if valid_candidates.has(character):
			valid_candidates[character].append(move)
		else:
			valid_candidates[character] = [move]
	
	var i = 0
	for candidates in valid_candidates.values():
		if candidates.size() != 1:
			continue
		
		var move = candidates[0]
		
		if i > 0:
			label.append_text(", ")
		move.state.highlight = true
		_highlighted_moves.push_back(move)
		label.push_bgcolor(Color.BLACK)
		label.append_text(move.character.to_upper())
		label.pop()
		i += 1

	if _highlighted_moves.size() == 0:
		label.text = "Oops! No moves available. Press any key to restart."
		return

func stop() -> void:

	for move in _highlighted_moves:
		move.state.highlight = false

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, .69)
	
	await tween.finished
	
	queue_free()

func _input(event: InputEvent) -> void:
	if _highlighted_moves.is_empty() and event is InputEventKey:
		get_tree().change_scene("res://main.tscn")
