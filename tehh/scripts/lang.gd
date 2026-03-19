@tool
extends Resource
class_name LanguageUtils

@warning_ignore("unused_signal")
signal param_sent(quantity: float, replace: bool)

var default_spc: float = 0.1

func get_effects(text: String) -> Dictionary:
	var regex: RegEx = RegEx.create_from_string(r'(?<start>\[param ((?<param>\w*) ?=* ?(?<digit>(\d*\.)?\d+))*\])|(?<end>\[/param\])')
	var instances = regex.search_all(text)
	var placement: Dictionary = {}
	var characters_removed: int = 0
	for i in instances:
		var place = i.get_start() - characters_removed
		var param = i.get_string("param")
		var instance_char: int = i.get_end() - i.get_start()
		characters_removed += instance_char
		if i.get_string("end") != "":
			param = i.get_string("end")
		placement[place] = {
			"param" : {
				param : i.get_string("digit").to_float()
			}
		}
	return placement



func parse_text(text:String) -> String:
	var regex: RegEx = RegEx.create_from_string(r'(?<start>\[param ((?<param>\w*) ?=* ?(?<digit>(\d*\.)?\d+))*\])|(?<end>\[/param\])')
	var parsed_text = regex.sub(text, "", true)
	return parsed_text
