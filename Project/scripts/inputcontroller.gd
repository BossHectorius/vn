@tool
extends Control
class_name InputController

signal requested

@export var hide_textbox := false


func _input(event: InputEvent) -> void:
	if event.is_action("Continue") and Input.is_action_just_pressed("Continue"):
		emit_signal("requested")
