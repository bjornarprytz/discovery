extends Node2D
class_name TextGame

@onready var segment_spawner = preload("res://logic/text-segment.tscn")
@onready var LINE_LENGTH : int = Global.corpus_line_length
@onready var SEGMENT_HEIGHT : int = Global.segment_height * Global.corpus_line_length
@onready var SEGMENT_WIDTH : int = Global.segment_width

var current_pos : int = 0

var center_segment : TextSegment
var north_segment : TextSegment
var east_segment : TextSegment
var south_segment : TextSegment
var west_segment : TextSegment

var ne_segment : TextSegment
var se_segment : TextSegment
var sw_segment : TextSegment
var nw_segment : TextSegment


var up : MoveCandidate
var right : MoveCandidate
var down : MoveCandidate
var left : MoveCandidate

class MoveCandidate:
	var destination : int
	var character: String
	var state: Corpus.CharState
	var step : Vector2

func _ready() -> void:
	var random_start = randi_range(0, Global.corpus.length()-1)
	var upper_left : int = random_start - ((SEGMENT_WIDTH + SEGMENT_HEIGHT) * 1.5)
	
	for y in range(3):
		for x in range(3):
			var segment = segment_spawner.instantiate() as TextSegment
			segment.set_start_index(upper_left + (x * SEGMENT_WIDTH) + (y * SEGMENT_HEIGHT))
			add_child(segment)
			
			segment.position = -segment.size + Vector2(segment.size.x * x, segment.size.y * y)
			
	nw_segment = get_child(0)
	north_segment = get_child(1)
	ne_segment = get_child(2)
	west_segment = get_child(3)
	center_segment = get_child(4)
	east_segment = get_child(5)
	sw_segment = get_child(6)
	south_segment = get_child(7)
	se_segment = get_child(8)
	
	_visit(center_segment.start_index)
	_refresh_text()

func try_move(input : String) -> void:
	if (input.length() > 1):
		return
	
	_reset_word_state()
	
	var visited = [up, right, down, left].filter(func (c: MoveCandidate): return c.state.visited)
	var not_visited = [up, right, down, left].filter(func (c: MoveCandidate): return !c.state.visited)
	
	var invalid = not_visited.filter(func (c1: MoveCandidate): return not_visited.filter(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0).size() > 1)
	var valid = not_visited.filter(func (c: MoveCandidate): return Global.valid_regex.search(c.character) != null).filter(func (c1: MoveCandidate): return !invalid.any(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0))
	
	if valid.is_empty():
		Global.game_over.emit()
	
	for candidate in valid:
		if (input.nocasecmp_to(candidate.character) == 0):
			var score = _visit(candidate.destination)
			Global.moved.emit(candidate.step, score)
			
	if invalid.any(func (cand: MoveCandidate): return input.nocasecmp_to(cand.character) == 0):
		for d in invalid:
			Global.get_state((d as MoveCandidate).destination).invalid_move = true
	
	_refresh_text()

func _visit(target_idx: int) -> int:
	var prev_state = Global.get_state(current_pos) as Corpus.CharState
	prev_state.cursor = false
	prev_state.visited = true
	
	var next_state = Global.get_state(target_idx) as Corpus.CharState
	next_state.cursor = true
	
	current_pos = target_idx
	var score = 1 # Base score for moving
	
	# TODO: add score per letter in a completed word, double if it's a quest word
	var word = Global.get_word_of(target_idx) as Corpus.WordData
	
	if (word != null and word.states.all(func (s : Corpus.CharState): return s.visited or s.cursor)):
		score += word.word.length()
		
		var is_target = Global.current_target.nocasecmp_to(word.word) == 0
		
		for s in word.states:
			s.completed_word = true
			if (is_target):
				s.quest = true
		
		if (is_target):
			Global.completed_quest.emit(word.word)
	
	if north_segment.contains_idx(current_pos):
		_shift_north()
	elif east_segment.contains_idx(current_pos):
		_shift_east()
	elif south_segment.contains_idx(current_pos):
		_shift_south()
	elif west_segment.contains_idx(current_pos):
		_shift_west()
	
	for c in [up, right, down, left]:
		if (c != null):
			c.state.invalid_move = false
	
	up = _create_candidate(current_pos - LINE_LENGTH, Global.font_size * Vector2.UP)
	right = _create_candidate(current_pos +1, Global.font_size * Vector2.RIGHT)
	down = _create_candidate(current_pos + LINE_LENGTH, Global.font_size * Vector2.DOWN)
	left = _create_candidate(current_pos -1,  Global.font_size * Vector2.LEFT)
	
	return score

func _reset_word_state():
	var word = Global.get_word_of(current_pos) as Corpus.WordData
	if (word != null and word.states.all(func (s : Corpus.CharState): return s.visited or s.cursor)):
		for s in word.states:
			s.completed_word = false

func _refresh_text():
	for s in get_children():
		(s as TextSegment).refresh()

func _create_candidate(target_idx: int, step: Vector2) -> MoveCandidate:
	var candidate = MoveCandidate.new()
	candidate.character = Global.get_char_at(target_idx)
	candidate.destination = target_idx
	candidate.state = Global.get_state(target_idx)
	candidate.step = step
	return candidate
	

func _shift_north():
	var new_upper_left : int = nw_segment.start_index - (SEGMENT_HEIGHT)
	var move_by = center_segment.size.y * 3
	
	var temp_segment = sw_segment
	sw_segment = west_segment
	west_segment = nw_segment
	nw_segment = temp_segment
	nw_segment.set_start_index(new_upper_left)
	nw_segment.position.y -= move_by
	
	temp_segment = south_segment
	south_segment = center_segment
	center_segment = north_segment
	north_segment = temp_segment
	north_segment.set_start_index(new_upper_left + SEGMENT_WIDTH)
	north_segment.position.y -= move_by
	
	temp_segment = se_segment
	se_segment = east_segment
	east_segment = ne_segment
	ne_segment = temp_segment
	ne_segment.set_start_index(new_upper_left + (SEGMENT_WIDTH * 2))
	ne_segment.position.y -= move_by

		
func _shift_east():
	var new_upper_right : int = ne_segment.start_index + SEGMENT_WIDTH
	var move_by = (center_segment.size.x * 3)

	var temp_segment = nw_segment
	nw_segment = north_segment
	north_segment = ne_segment
	ne_segment = temp_segment
	ne_segment.set_start_index(new_upper_right)
	ne_segment.position.x += move_by

	temp_segment = west_segment
	west_segment = center_segment
	center_segment = east_segment
	east_segment = temp_segment
	east_segment.set_start_index(new_upper_right + (SEGMENT_HEIGHT))
	east_segment.position.x += move_by

	temp_segment = sw_segment
	sw_segment = south_segment
	south_segment = se_segment
	se_segment = temp_segment
	se_segment.set_start_index(new_upper_right + (2 * SEGMENT_HEIGHT))
	se_segment.position.x += move_by

func _shift_south():
	var new_lower_left : int = sw_segment.start_index + (SEGMENT_HEIGHT)
	var move_by = center_segment.size.y * 3

	var temp_segment = nw_segment
	nw_segment = west_segment
	west_segment = sw_segment
	sw_segment = temp_segment
	sw_segment.set_start_index(new_lower_left)
	sw_segment.position.y += move_by
	
	temp_segment = north_segment
	north_segment = center_segment
	center_segment = south_segment
	south_segment = temp_segment
	south_segment.set_start_index(new_lower_left + SEGMENT_WIDTH)
	south_segment.position.y += move_by
	
	temp_segment = ne_segment
	ne_segment = east_segment
	east_segment = se_segment
	se_segment = temp_segment
	se_segment.set_start_index(new_lower_left + (SEGMENT_WIDTH * 2))
	se_segment.position.y += move_by

func _shift_west():
	var new_upper_left : int = nw_segment.start_index - SEGMENT_WIDTH
	var move_by = (center_segment.size.x * 3)
	
	var temp_segment = ne_segment
	ne_segment = north_segment
	north_segment = nw_segment
	nw_segment = temp_segment
	nw_segment.set_start_index(new_upper_left)
	nw_segment.position.x -= move_by

	temp_segment = east_segment
	east_segment = center_segment
	center_segment = west_segment
	west_segment = temp_segment
	west_segment.set_start_index(new_upper_left + (SEGMENT_HEIGHT))
	west_segment.position.x -= move_by

	temp_segment = se_segment
	se_segment = south_segment
	south_segment = sw_segment
	sw_segment = temp_segment
	sw_segment.set_start_index(new_upper_left + (2 * SEGMENT_HEIGHT))
	sw_segment.position.x -= move_by

