extends TextureRect
class_name bgDisplayer

const ANIMATIONS := ["fade_in", "fade_out"]

@onready var anim_player: AnimationPlayer = $AnimationPlayer

signal anim_finished


func display_bg(bg: Background, anim: String = "") -> void:
	texture = bg.texture
	if anim != "" and anim in ANIMATIONS:
		anim_player.play(anim)

func set_max_dist(value: float) -> void:
	set_instance_shader_parameter("max_dist", value)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	print("bg finish")
	anim_finished.emit()
