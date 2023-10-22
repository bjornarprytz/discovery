@tool

extends Node2D

@onready var segment_spawner = preload("res://logic/text-segment.tscn")

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_pos = randi_range(0, Autoload.corpus.length()-1)
	Autoload.visited.push_front(current_pos)
	
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

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_released()):
		
		var key = event.as_text()
		if (key == "W"):
			_shift_north()
		if (key == "S"):
			_shift_south()
		if (key == "D"):
			_shift_east()
		if (key == "A"):
			_shift_west()
		if (try_move(key, current_pos - Autoload.corpus_line_length)):
			print("Moved up ", current_pos, " ", key)
			if (north_segment.contains_idx(current_pos)):
				_shift_north()
			return
		if (try_move(key, current_pos +1)):
			print("Moved right ", current_pos, " ", key)
			if (east_segment.contains_idx(current_pos)):
				_shift_east()
			return
		if (try_move(key, current_pos + Autoload.corpus_line_length)):
			print("Moved down ", current_pos, " ", key)
			if (south_segment.contains_idx(current_pos)):
				_shift_south()
			return
		if (try_move(key, current_pos -1)):
			print("Moved left ", current_pos, " ", key)
			if (west_segment.contains_idx(current_pos)):
				_shift_west()

func try_move(c : String, t_idx : int) -> bool:
	if (c.length() > 1):
		return false
	
	var target_char = Autoload.get_char_at(t_idx)
	if (c.nocasecmp_to(target_char) == 0):
		current_pos = t_idx
		return true
		
	return false

func _shift_north():
	var new_upper_left : int = nw_segment.start_index - (Autoload.segment_height * Autoload.corpus_line_length)
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
	north_segment.set_start_index(new_upper_left + Autoload.segment_width)
	north_segment.position.y -= move_by
	
	temp_segment = se_segment
	se_segment = east_segment
	east_segment = ne_segment
	ne_segment = temp_segment
	ne_segment.set_start_index(new_upper_left + (Autoload.segment_width * 2))
	ne_segment.position.y -= move_by

		
func _shift_east():
	var new_upper_right : int = ne_segment.start_index + Autoload.segment_width
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
	east_segment.set_start_index(new_upper_right + (Autoload.segment_height * Autoload.corpus_line_length))
	east_segment.position.x += move_by

	temp_segment = sw_segment
	sw_segment = south_segment
	south_segment = se_segment
	se_segment = temp_segment
	se_segment.set_start_index(new_upper_right + (2 * Autoload.segment_height * Autoload.corpus_line_length))
	se_segment.position.x += move_by

func _shift_south():
	var new_lower_left : int = sw_segment.start_index + (Autoload.segment_height * Autoload.corpus_line_length)
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
	south_segment.set_start_index(new_lower_left + Autoload.segment_width)
	south_segment.position.y += move_by
	
	temp_segment = ne_segment
	ne_segment = east_segment
	east_segment = se_segment
	se_segment = temp_segment
	se_segment.set_start_index(new_lower_left + (Autoload.segment_width * 2))
	se_segment.position.y += move_by

func _shift_west():
	var new_upper_left : int = nw_segment.start_index - Autoload.segment_width
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
	west_segment.set_start_index(new_upper_left + (Autoload.segment_height * Autoload.corpus_line_length))
	west_segment.position.x -= move_by

	temp_segment = se_segment
	se_segment = south_segment
	south_segment = sw_segment
	sw_segment = temp_segment
	sw_segment.set_start_index(new_upper_left + (2 * Autoload.segment_height * Autoload.corpus_line_length))
	sw_segment.position.x -= move_by

