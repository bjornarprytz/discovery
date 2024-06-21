class_name Validation

static func _init_regex() -> RegEx:
    var regex = RegEx.new()
    regex.compile("\\w+")
    return regex
static var _valid_regex: RegEx = _init_regex()

static func is_char_valid(_letter: String) -> bool:
    return _valid_regex.search(_letter) != null

static func get_matches(text: String) -> Array[RegExMatch]:
    return _valid_regex.search_all(text)