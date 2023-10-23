extends Node2D
class_name State

signal moved(step: Vector2)

const MARK_COLOR: Color = Color.CRIMSON
const font_size : Vector2 = Vector2(102.0, 256.0)
var corpus_line_length : int = 64
var segment_width : int = 12
var segment_height : int = 3

var current_target : String

var words : Array[String] = []
var visited : Array[bool] = []

@onready var corpus = "
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lobortis mattis aliquam faucibus purus in massa. In massa tempor nec feugiat nisl pretium fusce. Facilisi morbi tempus iaculis urna id. Nibh praesent tristique magna sit amet purus gravida quis. Tincidunt ornare massa eget egestas purus viverra. Condimentum vitae sapien pellentesque habitant morbi tristique senectus et netus. Quis hendrerit dolor magna eget est. Vitae et leo duis ut. Viverra mauris in aliquam sem fringilla ut morbi tincidunt augue. Tempus quam pellentesque nec nam. Velit ut tortor pretium viverra suspendisse potenti. Amet cursus sit amet dictum sit amet. A condimentum vitae sapien pellentesque habitant morbi tristique senectus et. Habitant morbi tristique senectus et netus et malesuada fames. Turpis tincidunt id aliquet risus feugiat in ante metus.
Arcu ac tortor dignissim convallis aenean. Proin sed libero enim sed faucibus turpis. Sagittis purus sit amet volutpat consequat mauris nunc congue. Viverra vitae congue eu consequat. Nisl suscipit adipiscing bibendum est ultricies integer. Turpis massa sed elementum tempus. Odio eu feugiat pretium nibh. Morbi non arcu risus quis varius quam quisque id diam. Sed enim ut sem viverra aliquet eget sit amet tellus. Commodo nulla facilisi nullam vehicula ipsum a arcu. Consequat mauris nunc congue nisi vitae. Nibh ipsum consequat nisl vel pretium lectus. Rhoncus est pellentesque elit ullamcorper dignissim cras tincidunt. Facilisis mauris sit amet massa vitae. Purus sit amet luctus venenatis lectus magna fringilla. Sapien eget mi proin sed. Viverra orci sagittis eu volutpat odio facilisis. Urna nec tincidunt praesent semper feugiat nibh sed pulvinar proin. Urna id volutpat lacus laoreet non curabitur. Dictum fusce ut placerat orci.
Sit amet commodo nulla facilisi. Blandit aliquam etiam erat velit scelerisque in dictum non consectetur. Mauris in aliquam sem fringilla ut morbi tincidunt. Lectus nulla at volutpat diam ut. Donec ultrices tincidunt arcu non sodales neque sodales ut etiam. Pharetra sit amet aliquam id diam. Enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac. Ut venenatis tellus in metus vulputate eu scelerisque felis imperdiet. Morbi enim nunc faucibus a pellentesque sit amet. Eu mi bibendum neque egestas congue quisque. Vitae proin sagittis nisl rhoncus mattis rhoncus urna. Purus non enim praesent elementum facilisis. Ultricies leo integer malesuada nunc vel risus commodo viverra maecenas. Diam quis enim lobortis scelerisque fermentum dui faucibus in. Faucibus nisl tincidunt eget nullam non nisi.
Iaculis urna id volutpat lacus laoreet non. Orci dapibus ultrices in iaculis nunc sed augue. Pulvinar mattis nunc sed blandit libero volutpat sed cras ornare. Cursus sit amet dictum sit. Dolor sit amet consectetur adipiscing elit pellentesque. Tellus at urna condimentum mattis. Eget magna fermentum iaculis eu non. Pellentesque sit amet porttitor eget dolor morbi non arcu. Et ultrices neque ornare aenean euismod elementum. Mi bibendum neque egestas congue quisque egestas. Morbi blandit cursus risus at ultrices mi tempus imperdiet nulla. Consequat semper viverra nam libero justo laoreet sit. Ultrices sagittis orci a scelerisque purus semper eget. Sit amet consectetur adipiscing elit duis tristique sollicitudin nibh. Scelerisque viverra mauris in aliquam sem fringilla ut morbi. Ut placerat orci nulla pellentesque dignissim enim sit. Duis ut diam quam nulla porttitor massa id. A pellentesque sit amet porttitor eget dolor. Vestibulum morbi blandit cursus risus at ultrices. Egestas erat imperdiet sed euismod nisi porta lorem mollis.
Gravida arcu ac tortor dignissim convallis aenean. Odio ut enim blandit volutpat maecenas volutpat. Fermentum iaculis eu non diam phasellus vestibulum lorem sed. Quam id leo in vitae turpis massa sed elementum tempus. Semper risus in hendrerit gravida rutrum. Metus dictum at tempor commodo ullamcorper a lacus. Tincidunt praesent semper feugiat nibh sed pulvinar. Cras sed felis eget velit aliquet sagittis id. Pulvinar pellentesque habitant morbi tristique senectus. Phasellus egestas tellus rutrum tellus pellentesque eu. Magna fermentum iaculis eu non diam. Urna et pharetra pharetra massa massa ultricies mi. In nibh mauris cursus mattis molestie a iaculis at erat. Eleifend donec pretium vulputate sapien nec sagittis aliquam. Faucibus turpis in eu mi bibendum neque egestas congue. Feugiat nisl pretium fusce id velit ut tortor pretium viverra. Consectetur lorem donec massa sapien faucibus et molestie. Pellentesque eu tincidunt tortor aliquam nulla facilisi. Arcu cursus vitae congue mauris rhoncus. Pellentesque habitant morbi tristique senectus et netus et.
"
func visit(idx: int) -> void:
	var normalized_idx = normalize_idx(idx)
	print("Visiting ", normalized_idx, " ", get_char_at(idx))
	assert(!visited[normalized_idx])
	visited[normalized_idx] = true

func is_visited(idx: int) -> bool:
	var normalized_idx = normalize_idx(idx)
	return visited[normalized_idx]

func get_char_at(idx: int) -> String:
	var normalized_idx = normalize_idx(idx)
	
	return corpus[normalized_idx]

func normalize_idx(idx: int) -> int:
	var n = idx % corpus.length()
	
	while n < 0:
		n += corpus.length()
	
	return n


func _ready() -> void:
	assert(segment_width <= corpus_line_length)
	assert(segment_height > 0)
	assert(segment_width > 0)
	
	corpus = corpus.replace("\n", " ").replace("  ", " ")
	visited.resize(corpus.length())
	
	for w in corpus.split(" ", false):
		words.push_back(w.replace(".", "").to_lower())
	
	current_target = words.pick_random()

