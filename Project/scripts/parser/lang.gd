extends Resource
class_name LanguageUtils

const EFFECTS := {
	COMMAND = "command",
	CONSTANT = "constant"
}

const EFFECTTYPES := {
	SLOW = "slow",
	FAST = "fast"
}

const EFFECTCOMMANDS := {
	SPEED = "speed",
	MSPEED = "mspeed",
	PAUSE = "pause"
}

const COMPSYMBOLS := ["=", ">", "<"]

class effect:
	var type: String
	var value
	var placement: int
	var end_placement: int
	
	func _init(_type: String, _value) -> void:
		self.type = _type
		self.value = _value

class functioneffect:
	extends effect
	var parameters := []
	
	func _init(_type: String, _value, _params: Array) -> void:
		self.type = _type
		self.value = _value
		self.parameters = _params

class dialogue:
	var text: String
	var index := 0
	
	func _init(_text: String) -> void:
		self.text = _text
	
	func _is_at_end() -> bool:
		return self.index == (self.text.length() -1)
	
	func _back() -> String:
		if index - 1 >= 0:
			return self.text[self.index - 1]
		push_error("Reached the start of the text")
		return ""
	
	func _next() -> String:
		if !_is_at_end():
			index += 1
			return self.text[self.index]
		push_error("Reached the end of the text")
		return ""
	
	func _get_current() -> String:
		return self.text[self.index]
	
	func _get_next() -> String:
		if not _is_at_end() && index +1 != len(text) - 1:
			return self.text[self.index + 1]
		push_error("Cannot see further")
		return ""
	

##Will check for special, custom effects in the text (like slowing the text)
##Text given must not contain BBCode (AKA, it has to be parsed already)
##It will return a dictionary where its keys are the number of where the effect should
##start and where its values are the effect itself.
func get_effects(text: String) -> Dictionary:
	var dialog := dialogue.new(text)
	var placement: Dictionary
	var character: String = dialog._get_current()
	var total_chars_removed: int = 0
	while not dialog._is_at_end():
		if character == "[":
			var brackeff := get_bracket_effects(dialog)
			brackeff.placement -= total_chars_removed
			brackeff.end_placement -= total_chars_removed
			placement[brackeff.placement] = brackeff
			total_chars_removed += brackeff.end_placement - brackeff.placement + 1
		character = dialog._next()
	return placement

##Gets the first word from the brackets which should be the command 
##and cheks what command it is.
##It then gets its parameters, if it needs them, and returns the corresponding effect.
func get_bracket_effects(dialog: dialogue) -> effect:
	var eff: effect
	var regex := RegEx.create_from_string(r'[a-z0-9A-Z]')
	var type: String = ""
	var first_idx: int = dialog.index
	while not dialog._is_at_end():
		var chara := dialog._next()
		if regex.search(chara):
			type += chara
		elif chara in [" ", "	", "\n", "\r", ":", "]"]:
			dialog._back()
			break
		else:
			push_error("unrecognized character %s" % chara)
	if type in EFFECTTYPES.values():
		eff = effect.new(EFFECTS.CONSTANT, type)
		eff.placement = first_idx
		eff.end_placement = dialog.index
	elif type in EFFECTCOMMANDS.values():
		eff = functioneffect.new(EFFECTS.COMMAND, type, get_params(dialog))
		eff.end_placement = dialog.index
		eff.placement = first_idx
	return eff

##Given an array with the effects and the text, it will parse the text and return a clean one
func parse_text(text:String, to_replace: Array) -> String:
	var new_text: String = text
	#var to_ignore: int = 0
	for replace in to_replace:
		if replace is effect:
			var to_erase := new_text.erase(replace.placement, replace.end_placement - replace.placement + 1)
			new_text = to_erase
	return new_text

##Goes through everything inside of the brackets and separates everything within
##everything that is between spaces counts as a new parameter
func get_params(dialog: dialogue) -> Array:
	var parameters: Array
	var regex := RegEx.create_from_string(r'[a-z0-9A-Z\.]')
	var param: String = ""
	while not dialog._is_at_end():
		var chara = dialog._next()
		if chara in COMPSYMBOLS:
			continue
		elif regex.search(chara):
			param += chara
		elif chara == "]":
			dialog._back()
			break
	parameters.append(param)
	return parameters
