extends Control
class_name textcontroller

#seconds per character revealed
@export_range(0, 5) var spc: float = 1
#the labels for the text and the name of the character that's speaking
@onready var text: RichTextLabel = $Panel/RichTextLabel
@onready var name_display: RichTextLabel = $Name/nameholder

var revealing: bool = false
var step: float = 0.0
var effects:Dictionary

signal next_requested

##Reveals characters one at a time and checks if they have some special effect attached.
func reveal_char() -> void:
	if text.visible_characters <= text.get_parsed_text().length():
		revealing = false
		if text.visible_characters == -1:
			return
		revealing = true
		text.visible_characters += 1
		if text.visible_characters in effects.keys():
			var eff: LanguageUtils.effect = effects[text.visible_characters]
			print("effect at %s with type of %s and value of %s" % [text.visible_characters, eff.type, eff.value])
			apply_effect(effects[text.visible_characters])
		

	else:
		revealing = false

func apply_effect(eff: LanguageUtils.effect) -> void:
	if eff.type in LanguageUtils.EFFECTS.COMMAND and eff is LanguageUtils.functioneffect:
		var param: String = eff.parameters[0]
		var digit: String = param.get_slice("=", 1)
		match eff.value:
			LanguageUtils.EFFECTCOMMANDS.SPEED:
				_change_speed(str_to_var(digit))
			LanguageUtils.EFFECTCOMMANDS.PAUSE:
				_pause(str_to_var(digit))
			LanguageUtils.EFFECTCOMMANDS.MSPEED:
				_change_speed(str_to_var(digit), false)
	elif eff.type == LanguageUtils.EFFECTS.CONSTANT:
		match eff.value:
			LanguageUtils.EFFECTTYPES.SLOW:
				_change_speed(1.5, false)
			LanguageUtils.EFFECTTYPES.FAST:
				_change_speed(0.5, false)

##Changes text speed. Can either replace the speed or be multiplied to it.
func _change_speed(delay: float, replace: bool = true) -> void:
	if replace:
		spc = delay
	else:
		spc *= delay

func _process(_delta: float) -> void:
	if !revealing:
		return
	step += _delta
	while revealing && step > spc:
		step -= spc
		reveal_char()

##Changes the text to _new_text. If additive is true, it is added instead of replaced.
func change_text(_new_text: String, additive: bool = false, character_name: String = "") -> void:
	var text_parser := LanguageUtils.new()
	text.visible_characters = 0
	revealing = true
	name_display.text = character_name
	if additive:
		var old_length: int = text.get_parsed_text().length()
		text.text += _new_text
		text.visible_characters = old_length
	else:
		text.text = _new_text
	
	effects = text_parser.get_effects(text.get_parsed_text())
	text.text = text_parser.parse_text(text.text, effects.values())
	name_display.show()
	name_display.get_parent().show()
	if name_display.text == "":
		name_display.hide()
		name_display.get_parent().hide()

func _pause(time: float) -> void:
	revealing = false
	step = 0
	var tween := create_tween()
	tween.tween_callback(_pause_finished).set_delay(time)

func _pause_finished() -> void:
	revealing = true



func finish() -> void:
	text.visible_characters = -1
	step = 0
	if revealing:
		return
	emit_signal("next_requested")
