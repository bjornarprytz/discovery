extends Node2D
class_name TextGame

var _segment_rows: int = 3
var _segment_columns: int = 3

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
		return _segments[_segment_rows / 2][_segment_columns / 2]

func force_refresh():
	for segment in _get_flat_segments():
		segment.refresh(true)

func queue_full_refresh():
	for segment in _get_flat_segments():
		segment.dirty = true

func resize(new_rows: int, new_columns: int, reassign_ambiance: bool = false):
	assert(new_rows > 0 and new_columns > 0, "Invalid size")
	if new_rows == _segment_rows and new_columns == _segment_columns:
		return

	if new_rows > _segment_rows:
		for i in range(new_rows - _segment_rows):
			_add_segments(Vector2.RIGHT if i % 2 == 0 else Vector2.LEFT)
	elif new_rows < _segment_rows:
		for i in range(_segment_rows - new_rows):
			_remove_segments(Vector2.RIGHT if i % 2 == 0 else Vector2.LEFT)
		
	if new_columns > _segment_columns:
		for i in range(new_columns - _segment_columns):
			_add_segments(Vector2.DOWN if i % 2 == 0 else Vector2.UP)
	elif new_columns < _segment_columns:
		for i in range(_segment_columns - new_columns):
			_remove_segments(Vector2.DOWN if i % 2 == 0 else Vector2.UP)

	_segment_rows = new_rows
	_segment_columns = new_columns

	if reassign_ambiance:
		_assign_ambiance_streams()
	
	_refresh_text()

func _ready() -> void:
	Game.ready_to_move.connect(_refresh_text)
	Game.moved.connect(_on_moved)
	Game.invalid_move.connect(_on_invalid_move)
	Game.new_quest.connect(_on_new_quest)
	
	var random_start = randi_range(0, Corpus.corpus.length() - 1)
	var upper_left: int = random_start - ((SEGMENT_WIDTH + SEGMENT_HEIGHT) * 1.5)
	
	_create_segments(upper_left)

	_assign_ambiance_streams()

func _create_segments(upper_left: int):
	# Create grid of segments
	for y in range(_segment_rows):
		var row = []
		for x in range(_segment_columns):
			var segment = segment_spawner.instantiate() as TextSegment
			var start_index = upper_left + (x * SEGMENT_WIDTH) + (y * SEGMENT_HEIGHT)
			segment.set_start_index(start_index)
			add_child(segment)
			segment.position = -segment.size + Vector2(segment.size.x * x, segment.size.y * y)
			row.append(segment)
		_segments.append(row)
	

func _assign_ambiance_streams():
	ambiance_streams.shuffle()

	for s in _get_flat_segments():
		var ambiance = ambiance_streams.pop_front()
		
		s.ambiance.stream = ambiance
		s.ambiance.play(randf_range(0, ambiance.get_length() - 1))

		ambiance_streams.append(ambiance)

func _on_moved(prev_pos: int, current_pos: int, _step: Vector2, _score_change: int):
	var camera_point = cam.position

	var current_segment_index = _get_segment_under_camera(camera_point)

	if current_segment_index.x == 0:
		_shift_segments(Vector2.LEFT)
	elif current_segment_index.x == _segment_columns - 1:
		_shift_segments(Vector2.RIGHT)
	
	if current_segment_index.y == 0:
		_shift_segments(Vector2.UP)
	elif current_segment_index.y == _segment_rows - 1:
		_shift_segments(Vector2.DOWN)

	_set_dirty_within(2, 2, prev_pos)

	for segment in _segments_touched_by_word_at(current_pos):
		segment.dirty = true
	for segment in _segments_touched_by_word_at(prev_pos):
		segment.dirty = true
	for segment in _segments_containing_indexes([prev_pos, current_pos]):
		segment.dirty = true


func _get_segment_under_camera(camera_point: Vector2) -> Vector2i:
	# Iterate through all segments to find the one the camera is over
	for row in range(_segment_rows):
		for col in range(_segment_columns):
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
	var vertical_text_shift: int = SEGMENT_HEIGHT * _segment_rows
	var horizontal_text_shift: int = SEGMENT_WIDTH * _segment_columns

	var vertical_pixel_shift: float = _segments[0][0].size.y * _segment_rows
	var horizontal_pixel_shift: float = _segments[0][0].size.x * _segment_columns

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

	_refresh_text()

func _add_segments(dir: Vector2i):
	match dir.x:
		1:
			for row in _segments:
				var segment = segment_spawner.instantiate() as TextSegment

				var rightmost_segment = row[-1]

				segment.set_start_index(rightmost_segment.start_index + SEGMENT_WIDTH)
				segment.position = rightmost_segment.position + Vector2.RIGHT * rightmost_segment.size.x

				row.push_back(segment)
				add_child(segment)
		-1:
			for row in _segments:
				var segment = segment_spawner.instantiate() as TextSegment

				var leftmost_segment = row[0]

				segment.set_start_index(leftmost_segment.start_index - SEGMENT_WIDTH)
				segment.position = leftmost_segment.position + Vector2.LEFT * leftmost_segment.size.x

				row.push_front(segment)
				add_child(segment)

	match dir.y:
		1:
			var top_row = _segments[0]
			var new_top_row = []
			for segment in top_row:
				var new_segment = segment_spawner.instantiate() as TextSegment
				new_segment.set_start_index(segment.start_index + SEGMENT_HEIGHT)
				new_segment.position = segment.position + Vector2.UP * segment.size.y
				new_top_row.append(new_segment)
				add_child(new_segment)
				
			_segments.push_back(new_top_row)
		-1:
			var bottom_row = _segments[-1]
			var new_bottom_row = []
			for segment in bottom_row:
				var new_segment = segment_spawner.instantiate() as TextSegment
				new_segment.set_start_index(segment.start_index - SEGMENT_HEIGHT)
				new_segment.position = segment.position + Vector2.DOWN * segment.size.y
				new_bottom_row.append(new_segment)
				add_child(new_segment)
			_segments.push_front(new_bottom_row)

func _remove_segments(dir: Vector2i):
	match dir.x:
		1:
			for row in _segments:
				var segment = row.pop_front()
				segment.queue_free()
		-1:
			for row in _segments:
				var segment = row.pop_back()
				segment.queue_free()
	
	match dir.y:
		1:
			_segments.pop_front()
		-1:
			_segments.pop_back()

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
