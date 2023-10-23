@tool
extends RichTextLabel
class_name TextSegment

var start_index : int

var t : RichTextEffect

func contains_idx(idx: int) -> bool:
	# TODO: Check if this actually works
	
	var normalized_idx = Autoload.normalize_idx(idx)
	
	for l in range(Autoload.segment_height):
		if (start_index >= normalized_idx and normalized_idx >= Autoload.corpus_line_length):
			return true
		normalized_idx -= Autoload.corpus_line_length
			
	return false

func set_start_index(idx: int) -> void:
	var normalized_idx = Autoload.normalize_idx(idx)
	start_index = normalized_idx
	clear()
	for l in range(Autoload.segment_height):
		var line = _get_line(start_index + (l * Autoload.corpus_line_length))
		append_text(line)

func _get_line(idx: int) -> String:
	
	var corpus : String = Autoload.corpus
	var normalized_idx = Autoload.normalize_idx(idx)
	
	var line_end = normalized_idx + Autoload.segment_width
	
	if (line_end >= corpus.length()):
		return corpus.substr(normalized_idx) + corpus.substr(0, line_end - corpus.length())
	else:
		return corpus.substr(normalized_idx, Autoload.segment_width)

