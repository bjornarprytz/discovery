@tool

extends Node2D
class_name TextGame

@onready var segment_spawner = preload("res://logic/text-segment.tscn")
@onready var SEGMENT_HEIGHT : int = Autoload.segment_height * Autoload.corpus_line_length
@onready var SEGMENT_WIDTH : int = Autoload.segment_width

var current_pos : int = 0
var center : Vector2

var center_segment : TextSegment
var north_segment : TextSegment
var east_segment : TextSegment
var south_segment : TextSegment
var west_segment : TextSegment

var ne_segment : TextSegment
var se_segment : TextSegment
var sw_segment : TextSegment
var nw_segment : TextSegment

class MoveCandidate:
	var destination : int
	var character: String
	var visited: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_visit(randi_range(0, Autoload.corpus.length()-1))
	
	var upper_left : int = current_pos - (((Autoload.segment_width) + (Autoload.segment_height * Autoload.corpus_line_length)) * 1.5)
	
	for y in range(3):
		for x in range(3):
			var segment = segment_spawner.instantiate() as TextSegment
			segment.set_start_index(upper_left + (x * Autoload.segment_width) + (y * Autoload.segment_height * Autoload.corpus_line_length))
			add_child(segment)
			
			segment.position = -segment.size + Vector2(segment.size.x * x, segment.size.y * y)
			segment.modulate = Color.from_hsv(randf(),randf(),randf())
			
	center_segment = get_child(4)
	north_segment = get_child(1)
	ne_segment = get_child(2)
	east_segment = get_child(5)
	se_segment = get_child(8)
	south_segment = get_child(7)
	sw_segment = get_child(6)
	west_segment = get_child(3)
	nw_segment = get_child(0)
	center = (center_segment.size / 2) + Vector2(20.0, 20.0)

func try_move(input : String) -> bool:
	if (input.length() > 1):
		return false
		
	var up = _create_candidate(current_pos - SEGMENT_HEIGHT)
	var right = _create_candidate(current_pos +1)
	var down = _create_candidate(current_pos + SEGMENT_HEIGHT)
	var left = _create_candidate(current_pos -1)
	
	var visited = [up, right, down, left].filter(func (c: MoveCandidate): return c.visited)
	var not_visited = [up, right, down, left].filter(func (c: MoveCandidate): return !c.visited)
	
	var duplicates = not_visited.filter(func (c1: MoveCandidate): return not_visited.filter(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0).size() > 1)
	
	var viable = not_visited.filter(func (c1: MoveCandidate): return !duplicates.any(func (c2: MoveCandidate): return c1.character.nocasecmp_to(c2.character) == 0))
	
	for candidate in viable:
		if (input.nocasecmp_to(candidate.character) == 0):
			_visit(candidate.destination)
			return true
	
	if duplicates.any(func (cand: MoveCandidate): return input.nocasecmp_to(cand.character)):
		print("Tried to move to a duplicate")
	
	return false

func _visit(target_idx: int):
	# TODO update bbcodes
	Autoload.visit(target_idx)
	current_pos = target_idx
	print("new pos ", Autoload.get_char_at(current_pos), " ", current_pos)

func _create_candidate(target_idx: int) -> MoveCandidate:
	var candidate = MoveCandidate.new()
	candidate.character = Autoload.get_char_at(target_idx)
	candidate.destination = target_idx
	candidate.visited = Autoload.is_visited(target_idx)
	return candidate
	

func _shift_north():
	var new_upper_left : int = nw_segment.start_index - (SEGMENT_HEIGHT)
	var move_by = center_segment.size.y * 3
	print("Move y by: ", move_by)
	
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
	print("Move x by: ", move_by)

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
	print("Move y by: ", move_by)

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
	print("Move x by: ", move_by)

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

