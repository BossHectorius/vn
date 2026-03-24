extends NinePatchRect
class_name ChoiceDisplayer

const choice_button := "res://scripts/displayers/scenes/choiceButton.tscn"
signal decided(index: int)
signal finished_hiding
enum STATES{
	HIDDEN,
	SHOWN
}

var cur_state: STATES = STATES.HIDDEN


func _ready() -> void:
	modulate = Color(1, 1, 1, 0)
	

func _appear() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(self, "position", Vector2(476.0, 124.0), 0.3).from(Vector2(476.0, 324.0)).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0)).set_trans(Tween.TRANS_LINEAR)
	cur_state = STATES.SHOWN

func _disappear() -> void:
	var tween := create_tween()
	var picked: ChoiceButton = get_tree().get_first_node_in_group("picked")
	tween.finished.connect(picked.queue_free)
	tween.finished.connect(_on_tween_finished)
	tween.set_parallel()
	tween.tween_property(self, "position", Vector2(476.0, 324.0), 0.3).from(Vector2(476.0, 124.0)).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).from(Color.WHITE).set_trans(Tween.TRANS_LINEAR)
	

func display_choices(choices: Array) -> void:
	if cur_state == STATES.HIDDEN:
		_appear()
	var idx := 0
	for choice in choices:
		var choice_btn := ChoiceButton.new()
		choice_btn.text = choice.name
		choice_btn.size.x = self.size.x
		choice_btn.disabled = true
		choice_btn.target = choice.target
		add_child(choice_btn)
		var fut_pos: Vector2 = Vector2(0, choice_btn.size.y * idx)
		choice_btn.move_to(fut_pos, Vector2(0, 400), idx)
		idx += 1
	for child in get_children():
		if child is ChoiceButton:
			child.disabled = false
			child.choice.connect(_on_choice_pressed)

func clear_choices(picked: String) -> void:
	var _tween := create_tween()
	_tween.set_parallel()
	var idx: int = 0
	for choice in get_children():
		if choice.text == picked:
			continue
		_tween.finished.connect(choice.queue_free)
		_tween.tween_property(choice, "self_modulate", Color(1, 1, 1, 0), 0.3 + idx * 0.075).set_trans(Tween.TRANS_LINEAR)
		_tween.tween_property(choice, "position", choice.position + Vector2(0, 300), 0.3 + idx * 0.075).set_trans(Tween.TRANS_SPRING)
		idx += 1
	await _tween.finished
	_disappear()

func _on_choice_pressed(choice: String, index: int) -> void:
	clear_choices(choice)
	decided.emit(index)

func _on_tween_finished() -> void:
	cur_state = STATES.HIDDEN
	finished_hiding.emit()
