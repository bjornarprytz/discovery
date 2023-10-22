@tool
extends RichTextLabel
class_name TextSegment

var start_index : int

var t : RichTextEffect

func contains_idx(idx: int) -> bool:
	# TODO: Check if this actually works
	
	var normalized_idx = idx % Autoload.corpus.length()
	
	for l in range(Autoload.segment_height):
		if (start_index >= normalized_idx and normalized_idx >= Autoload.corpus_line_length):
			return true
		normalized_idx -= Autoload.corpus_line_length
			
	return false

func set_start_index(idx: int) -> void:
	start_index = idx
	text = ""
	for l in range(Autoload.segment_height):
		text = text + _get_line(start_index + (l * Autoload.corpus_line_length))

func _get_line(idx: int) -> String:
	var corpus : String = Autoload.corpus
	
	var line_end = idx + Autoload.segment_width
	
	if (line_end >= corpus.length()):
		return corpus.substr(idx) + corpus.substr(0, line_end - corpus.length())
	else:
		return corpus.substr(idx, Autoload.segment_width)

