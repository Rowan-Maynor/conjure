extends ScrollContainer

@onready var scroll_bar = self.get_v_scroll_bar()

func _ready() -> void:
	scroll_bar.connect("changed", _on_scroll_bar_changed)

func _on_scroll_bar_changed():
	self.scroll_vertical = scroll_bar.max_value
