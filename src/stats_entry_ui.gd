class_name StatsEntry
extends PanelContainer
@onready var category: RichTextLabel = %Category
@onready var separator: RichTextLabel = %Separator
@onready var value: RichTextLabel = %Value

const _rainbow_effect = "[rainbow freq=.2 sat=0.4]"
const _separator = "......................................................................................................................................................................................................................................................................"

func initialize(category_: String, value_: Variant, index: int) -> void:
	_category = category_
	_value = value_
	
	var color = Color(0, 0, 0, 1)
	if index % 2 == 0:
		color = Color(1, 1, 1, 1)
	self_modulate = color

var _category: String
var _value: Variant

func _ready() -> void:
	category.text = _category
	value.text = str(_value)

func highlight():
	category.clear()
	category.append_text("%s%s" % [_rainbow_effect, _category])

	separator.clear()
	separator.append_text("%s%s" % [_rainbow_effect, _separator])
	
	value.clear()
	value.append_text("%s%s" % [_rainbow_effect, str(_value)])


func unhighlight():
	category.clear()
	category.append_text(_category)

	separator.clear()
	separator.append_text(_separator)
	
	value.clear()
	value.append_text(str(_value))
