extends Node2D
class_name TextGame

const SEGMENT_ROWS = 3
const SEGMENT_COLS = 3

@export var cam: Camera2D

@onready var segment_spawner = preload ("res://logic/text-segment.tscn")
@onready var LINE_LENGTH: int = Corpus.corpus_line_length
@onready var SEGMENT_HEIGHT: int = Corpus.segment_height * Corpus.corpus_line_length
@onready var SEGMENT_WIDTH: int = Corpus.segment_width

var center_segment: TextSegment
var north_segment: TextSegment
var east_segment: TextSegment
var south_segment: TextSegment
var west_segment: TextSegment

var ne_segment: TextSegment
var se_segment: TextSegment
var sw_segment: TextSegment
var nw_segment: TextSegment

func force_refresh():
	_refresh_text()

func _ready() -> void:
	Game.moved.connect(_on_moved)
	Game.invalid_move.connect(_on_invalid_move)
	
	var random_start = randi_range(0, Corpus.corpus.length() - 1)
	var upper_left: int = random_start - ((SEGMENT_WIDTH + SEGMENT_HEIGHT) * 1.5)
	
	for y in range(SEGMENT_ROWS):
		for x in range(SEGMENT_COLS):
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
	
	Game.force_move(center_segment.start_index, true)

func _on_moved(_prev_pos: int, _current_pos: int, _step: Vector2, _score_change: int):

	var camera_point = cam.position
	
	if north_segment.get_rect().has_point(camera_point):
		_shift_north()
	elif east_segment.get_rect().has_point(camera_point):
		_shift_east()
	elif south_segment.get_rect().has_point(camera_point):
		_shift_south()
	elif west_segment.get_rect().has_point(camera_point):
		_shift_west()
	
	_refresh_text()

func _on_invalid_move():
	_refresh_text()

func _refresh_text():
	for s in get_children():
		(s as TextSegment).refresh()

func _shift_north():
	var new_upper_left: int = nw_segment.start_index - (SEGMENT_HEIGHT)
	var move_by = center_segment.size.y * SEGMENT_ROWS
	
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
	var new_upper_right: int = ne_segment.start_index + SEGMENT_WIDTH
	var move_by = (center_segment.size.x * SEGMENT_COLS)

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
	var new_lower_left: int = sw_segment.start_index + (SEGMENT_HEIGHT)
	var move_by = center_segment.size.y * SEGMENT_ROWS

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
	var new_upper_left: int = nw_segment.start_index - SEGMENT_WIDTH
	var move_by = (center_segment.size.x * SEGMENT_COLS)
	
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
