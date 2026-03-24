extends Button
class_name ChoiceButton

signal finished
signal choice(choice_name: String, target: int)

var target: int = 0

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func change_text(_text: String) -> void:
	text = _text


func move_to(new_pos: Vector2, start_pos: Vector2, idx: int) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(self, "position", start_pos - Vector2(0, 100), 0.2 + idx * 0.075).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).from(start_pos+ Vector2(0, 100))
	tween.tween_property(self, "modulate", Color.WHITE, 0.2 + idx * 0.075).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	tween.tween_property(self, "position", new_pos, 0.3 + idx * 0.075).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	


func _on_tween_finished() -> void:
	finished.emit()


func _on_button_pressed() -> void:
	self.add_to_group("picked")
	print(self.target)
	choice.emit(self.text, self.target)
