extends Resource
class_name Character

@export var name := "Display name"
@export var id: String = "name id"
@export_category("Expressions")
@export var images := {
	neutral = null,
	angry = null,
	happy = null,
	sad = null
}
@export var default_image := "neutral"

func _init() -> void:
	assert(default_image in images)

func get_default_image() -> Texture2D:
	return images[default_image]

func get_image(expression: String) -> Texture2D:
	return images.get(expression, get_default_image())
