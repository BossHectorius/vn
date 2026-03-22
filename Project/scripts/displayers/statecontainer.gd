extends NinePatchRect
class_name StateContainer

enum STATES{
	HIDDEN,
	SHOWN
}
@export var cur_state: STATES = STATES.HIDDEN
@export var default_height: float
@export var label: RichTextLabel

func set_state(state: STATES) -> void:
	cur_state = state

func anim_show() -> void:
	var tween := create_tween()
	if label:
		if label is HExtendLabel:
			label._extend_text()
		get_child(0).set_process(false)
	tween.finished.connect(on_tween_finished)
	tween.set_parallel()
	tween.tween_property(self, "position", Vector2(0, default_height) , 0.3).from(self.position + Vector2(0, 200)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	cur_state = STATES.SHOWN

func anim_hide() -> void:
	var tween := create_tween()
	if label:
		get_child(0).set_process(false)
	tween.finished.connect(on_tween_finished)
	tween.set_parallel()
	tween.tween_property(self, "position", self.position + Vector2(0, 200), 0.3).from(Vector2(0, default_height)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0) , 0.3).from(Color.WHITE).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	cur_state = STATES.HIDDEN

func on_tween_finished() -> void:
	get_child(0).set_process(true)
