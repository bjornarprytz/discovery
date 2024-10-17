class_name StatsEntry
extends PanelContainer
@onready var category: RichTextLabel = %Category
@onready var value: RichTextLabel = %Value

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
