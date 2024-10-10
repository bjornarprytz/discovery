extends Node2D
class_name TextGame

const SEGMENT_ROWS = 5
const SEGMENT_COLS = 5

@export var cam: Camera2D

@onready var segment_spawner = preload("res://logic/text-segment.tscn")
@onready var LINE_LENGTH: int = Corpus.corpus_line_length
@onready var SEGMENT_HEIGHT: int = Corpus.segment_height * Corpus.corpus_line_length
@onready var SEGMENT_WIDTH: int = Corpus.segment_width

var ambiance_streams: Array[AudioStream] = [
	preload("res://assets/ambiance/crackling-fire-14759.mp3"),
	preload("res://assets/ambiance/forest-jungle-nature-dark-atmo-6154.mp3"),
	preload("res://assets/ambiance/forest-wind-and-birds-6881.mp3"),
	preload("res://assets/ambiance/morning-forest-ambiance-17045.mp3"),
	preload("res://assets/ambiance/night-woods-7012.mp3"),
	preload("res://assets/ambiance/river-in-the-forest-17271.mp3"),
	preload("res://assets/ambiance/soft-rain-ambient-111154.mp3"),
	preload("res://assets/ambiance/underwater-whale-and-diving-sound-ambient-116185.mp3"),
	preload("res://assets/ambiance/wind-winter-trees-variable-gusts-70km-mono-clean-77mel-190208-19041.mp3")
]

var _segments: Array = []

var center_segment: TextSegment:
	get:
		return _segments[SEGMENT_ROWS / 2][SEGMENT_COLS / 2]

func force_refresh():
	for segment in _get_flat_segments():
		segment.refresh(true)

func queue_full_refresh():
	for segment in _get_flat_segments():
		segment.dirty = true

func _ready() -> void:
	Game.ready_to_move.connect(_refresh_text)
	Game.moved.connect(_on_moved)
	Game.invalid_move.connect(_on_invalid_move)
	Game.new_quest.connect(_on_new_quest)
	
	var random_start = randi_range(0, Corpus.corpus.length() - 1)
	var upper_left: int = random_start - ((SEGMENT_WIDTH + SEGMENT_HEIGHT) * 1.5)
	
	# Create grid of segments
	for y in range(SEGMENT_ROWS):
		var row = []
		for x in range(SEGMENT_COLS):
			var segment = segment_spawner.instantiate() as TextSegment
			var start_index = upper_left + (x * SEGMENT_WIDTH) + (y * SEGMENT_HEIGHT)
			segment.set_start_index(start_index)
			add_child(segment)
			segment.position = -segment.size + Vector2(segment.size.x * x, segment.size.y * y)
			row.append(segment)
		_segments.append(row)

	_assign_ambiance_streams()
		
	_refresh_text()

func _assign_ambiance_streams():
	ambiance_streams.shuffle()

	for s in _get_flat_segments():
		var ambiance = ambiance_streams.pop_front()
		
		s.ambiance.stream = ambiance
		s.ambiance.play(randi_range(0, s.ambiance.stream.get_length() - 1))

		ambiance_streams.append(ambiance)

func _on_moved(prev_pos: int, current_pos: int, _step: Vector2, _score_change: int):
	var camera_point = cam.position

	var current_segment_index = _get_segment_under_camera(camera_point)

	match current_segment_index.x:
		0:
			_shift_segments(Vector2.LEFT)
		SEGMENT_COLS - 1:
			_shift_segments(Vector2.RIGHT)
		_:
			pass
	
	match current_segment_index.y:
		0:
			_shift_segments(Vector2.UP)
		SEGMENT_ROWS - 1:
			_shift_segments(Vector2.DOWN)
		_:
			pass

	_set_dirty_within(2, 2, prev_pos)

	for segment in _segments_touched_by_word_at(current_pos):
		segment.dirty = true
	for segment in _segments_touched_by_word_at(prev_pos):
		segment.dirty = true
	for segment in _segments_containing_indexes([prev_pos, current_pos]):
		segment.dirty = true


func _get_segment_under_camera(camera_point: Vector2) -> Vector2i:
	# Iterate through all segments to find the one the camera is over
	for row in range(SEGMENT_ROWS):
		for col in range(SEGMENT_COLS):
			var segment = _segments[row][col]
			if segment.get_rect().has_point(camera_point):
				return Vector2(col, row) # Return the column and row of the segment
	return Vector2(-1, -1) # Return an invalid position if none is found


func _on_new_quest(_word: String):
	queue_full_refresh()

func _on_invalid_move():
	_set_dirty_within(2, 2)

func _get_camera_view_rect() -> Rect2:
	const cam_grace_factor = 1.2
	var cam_transform = cam.get_global_transform()
	var cam_size = cam_transform.get_scale() * cam.get_viewport_rect().size * cam_grace_factor
	var cam_pos = cam_transform.origin + cam.offset
	cam_pos = cam_pos - (cam_size / 2)

	return Rect2(cam_pos, cam_size)

func _refresh_text():
	var cam_rect = _get_camera_view_rect()
	for s in _get_flat_segments():
		if !s.get_rect().intersects(cam_rect):
			continue

		var segment = s as TextSegment
		segment.refresh()

func _shift_segments(dir: Vector2i):
	var vertical_text_shift: int = SEGMENT_HEIGHT * SEGMENT_ROWS
	var horizontal_text_shift: int = SEGMENT_WIDTH * SEGMENT_COLS

	var vertical_pixel_shift: float = _segments[0][0].size.y * SEGMENT_ROWS
	var horizontal_pixel_shift: float = _segments[0][0].size.x * SEGMENT_COLS

	match dir.x:
		1:
			for row in _segments:
				var segment_to_shift = row.pop_front()

				segment_to_shift.set_start_index(segment_to_shift.start_index + horizontal_text_shift)
				segment_to_shift.position.x += horizontal_pixel_shift

				row.push_back(segment_to_shift)
		-1:
			for row in _segments:
				var segment_to_shift = row.pop_back()

				segment_to_shift.set_start_index(segment_to_shift.start_index - horizontal_text_shift)
				segment_to_shift.position.x -= horizontal_pixel_shift

				row.push_front(segment_to_shift)
	
	match dir.y:
		1:
			var row_to_shift = _segments.pop_front()
			for segment in row_to_shift:
				segment.set_start_index(segment.start_index + vertical_text_shift)
				segment.position.y += vertical_pixel_shift
			_segments.push_back(row_to_shift)
		-1:
			var row_to_shift = _segments.pop_back()
			for segment in row_to_shift:
				segment.set_start_index(segment.start_index - vertical_text_shift)
				segment.position.y -= vertical_pixel_shift
			_segments.push_front(row_to_shift)

	_assign_ambiance_streams()

	_refresh_text()


func _set_dirty_within(horizontal_range: int, vertical_range: int, origin: int = -1):
	if origin == -1:
		origin = Game.current_pos
	var horizon_left = origin - horizontal_range
	var horizon_right = origin + horizontal_range
	var horizon_up = origin - (vertical_range * Corpus.corpus_line_length)
	var horizon_down = origin + (vertical_range * Corpus.corpus_line_length)

	for segment in _segments_containing_indexes([horizon_left, horizon_right, horizon_up, horizon_down]):
		segment.dirty = true

func _segments_touched_by_word_at(index: int) -> Array[TextSegment]:
	var current_word = Corpus.get_word_of(index)

	if current_word == null:
		return []

	var word_start = current_word.start_idx
	var word_end = word_start + current_word.word.length() - 1
	
	return _segments_containing_indexes([word_start, word_end])

func _segments_containing_indexes(indexes: Array[int]) -> Array[TextSegment]:
	var result_segments: Array[TextSegment] = []

	for segment in _get_flat_segments():
		if indexes.is_empty():
			break
		if result_segments.has(segment):
			continue
		for i in indexes:
			if segment.contains_idx(i):
				result_segments.append(segment)
				indexes.erase(i)
				break

	return result_segments

func _get_flat_segments() -> Array[TextSegment]:
	var flat_segments: Array[TextSegment] = []
	for row in _segments:
		for segment in row:
			flat_segments.append(segment as TextSegment)
	return flat_segments
