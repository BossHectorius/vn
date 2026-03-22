@tool
extends RichTextLabel
class_name HExtendLabel

@export_category("Options for extending the text")
@export var extend: bool = true


func _extend_text() -> void:
	var lsize: int = get_theme_font_size("normal_font_size")
	var new_size := lsize * len(text)
	if get_line_range(0).y < len(text):
		get_parent().size.x = new_size
	elif get_line_range(0).y == len(text) and size.x > new_size:
		get_parent().size.x = custom_minimum_size.x

func _process(_delta: float) -> void:
	if extend:
		_extend_text()
