extends Node2D
class_name CharacterDisplayer

signal display_finished




const SIDE := {
	LEFT = "left",
	RIGHT = "right",
	CENTER = "center"
}

const ANIMATIONS := {
	"enter" : "_enter",
	"leave" : "_leave"
}

const COLOR_TRANSPARENT = Color(1, 1, 1, 0)

var _tween: Tween

@onready var left: Sprite2D = $LEFT
@onready var right := $RIGHT
@onready var center := $CENTER

const left_pos = Vector2(158.0, 350.0)
const center_pos = Vector2(576.0, 350.0)
const right_pos = Vector2(986, 350)


func _ready() -> void:
	hide_everything()
	
	#_display(ResourceDB.get_character("test"), "left", "neutral", "enter")

func hide_everything() -> void:
	left.hide()
	right.hide()
	center.hide()

func _display(character: Character, side: String, expression: String, animation: String) -> void:
	var sprite: Sprite2D
	if side == SIDE.LEFT:
		sprite = left
	elif side == SIDE.RIGHT:
		sprite = right
	else:
		sprite = center
	
	sprite.texture = character.get_image(expression)
	sprite.modulate = Color.WHITE
	sprite.show()
	if animation != "":
		call(ANIMATIONS[animation], side, sprite)


func _leave(side: String, sprite: Sprite2D) -> void:
	var offset: int
	var end: Vector2
	if side == SIDE.LEFT:
		offset = -200
		end = left_pos
	elif side == SIDE.RIGHT:
		offset = 200
		end = right_pos
	else:
		offset = 100
		end = center_pos
	var start := sprite.position + Vector2(offset, 0)
	
	
	_tween = create_tween()
	_tween.finished.connect(_on_tween_finished)
	_tween.set_parallel(true)
	_tween.tween_property(
		sprite,
		"position",
		start,
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).from(end)
	_tween.tween_property(
		sprite, 
		"modulate",
		COLOR_TRANSPARENT,
		0.25
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR).from(Color.WHITE)


func _enter(side: String, sprite: Sprite2D) -> void:
	var offset: int
	var end: Vector2
	if side == SIDE.LEFT:
		offset = -200
		end = left_pos
	elif side == SIDE.RIGHT:
		offset = 200
		end = right_pos
	else:
		offset = 100
		end = center_pos
	var start := sprite.position + Vector2(offset, 0)
	
	
	_tween = create_tween()
	_tween.finished.connect(_on_tween_finished)
	_tween.set_parallel(true)
	_tween.tween_property(
		sprite,
		"position",
		end,
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).from(start)
	_tween.tween_property(
		sprite, 
		"modulate",
		Color.WHITE,
		0.25
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR).from(COLOR_TRANSPARENT)


func _on_tween_finished() -> void:
	print("animation finished")
	display_finished.emit()
