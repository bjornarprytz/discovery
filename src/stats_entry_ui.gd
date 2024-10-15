class_name StatsEntry
extends HBoxContainer
@onready var category: RichTextLabel = %Category
@onready var value: RichTextLabel = %Value

func initialize(category_: String, value_: float):
	_category = category_
	_value = value_

var _category: String
var _value: float

func _ready() -> void:
	category.text = _category
	value.text = str(_value)
