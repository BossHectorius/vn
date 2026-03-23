extends Camera2D
class_name MovingCam


#func _process(_delta: float) -> void:
	#var mouse_offset = (get_viewport().get_mouse_position() - get_viewport().size / 2.0)
	#offset = lerp(Vector2(), mouse_offset.normalized() * 500, mouse_offset.length() / 1000)/20
