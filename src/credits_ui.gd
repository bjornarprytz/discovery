extends Control

@onready var attribution_scroll: ScrollContainer = $AttributionScroll
@onready var attribution_text: RichTextLabel = $AttributionScroll/Attribution

func _ready() -> void:
	_scroll_up.call_deferred()

func _scroll_up():
	var scroll_up_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scroll_up_tween.tween_property(attribution_scroll, "scroll_vertical", 0, 5.0)
	scroll_up_tween.tween_interval(2.0)
	scroll_up_tween.tween_callback(_scroll_down)

func _scroll_down():
	var scroll_max = attribution_text.size.y - attribution_scroll.size.y

	var scroll_down_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scroll_down_tween.tween_property(attribution_scroll, "scroll_vertical", scroll_max, 5.0)
	scroll_down_tween.tween_interval(2.0)
	scroll_down_tween.tween_callback(_scroll_up)
