@tool
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
var Lang := LanguageUtils.new()

signal next_requested


func _ready() -> void:
	Lang.default_spc = spc
	Lang.connect("param_sent", param_changed)

##Reveals characters one at a time and checks if they have some special effect attached.
func reveal_char():
	if text.visible_characters <= text.get_parsed_text().length():
		revealing = false
		if text.visible_characters == -1:
			return
		revealing = true
		text.visible_characters += 1
		for changes in effects:
			if text.visible_characters == changes:
				var change: float = Lang.default_spc
				var type: Dictionary = effects[changes]["param"]
				if type.get("slow"):
					change = type["slow"]
				_change_speed(change)
	else:
		revealing = false

##Changes text speed. Can either replace the speed or be multiplied to it.
func _change_speed(delay: float, replace: bool = true):
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

func param_changed(value: float, replace: bool):
	_change_speed(value, replace)


##Changes the text to _new_text. If additive is true, it is added instead of replaced.
func change_text(_new_text: String, additive: bool = false, character_name: String = "") -> void:
	if !additive:
		name_display.text = character_name
		text.text = _new_text
		effects = Lang.get_effects(text.get_parsed_text())
		text.text = Lang.parse_text(text.text)
		text.visible_characters = 0
		revealing = true
	else:
		name_display.text = character_name
		var old_length = text.get_parsed_text().length()
		text.text += _new_text #append_text() doesn't actually change the text in-code
		#so it wouldn't work
		#because of this, we just add it normally.
		effects = Lang.get_effects(text.get_parsed_text())
		text.text = Lang.parse_text(text.text)
		text.visible_characters = old_length
		revealing = true
	
	if name_display.text == "":
		name_display.hide()
		name_display.get_parent().hide()
	else:
		name_display.show()
		name_display.get_parent().show()

func finish() -> void:
	text.visible_characters = -1
	step = 0
	if revealing:
		return
	emit_signal("next_requested")
