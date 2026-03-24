@tool
extends Resource
class_name Lexer

var symbol_regex := RegEx.create_from_string(r'[_a-zA-Z0-9]')

const TOKENTYPES := {
	STRING_LITERAL = "string_literal",
	SYMBOL = "symbol",
	NEWLINE = "newline",
	COMMAND = "command",
	BEGINBLOCK = "beginblock",
	ENDBLOCK = "endblock",
	START_OF_FILE = "start_of_file",
	CHOICE = "choice"
}

const CHOICE_KEYWORD := "choice"

const COMMANDS := {
	BACKGROUND = "bg",
	SCENE = "scene",
	JUMP = "jump",
	MARK = "mark",
	SET = "set",
	TRANSITION = "transition",
	CHARACTER = "chara",
	WAIT_ANIM = "wait_anim",
	WAIT_INPUT = "wait_input",
}
const CONDITIONALS := {
	IF = "if",
	ELIF = "elif",
	ELSE = "else"
}

class ScriptFile:
	var current_indent := 0
	var text := ""
	var current_index := 0
	var length := 0
	
	func _init(_text: String) -> void:
		self.text = _text
		self.length = len(self.text)
	
	func is_at_end() -> bool:
		return current_index == (length -1)
	
	func move_fw() -> String:
		if !is_at_end():
			current_index += 1
			return text[current_index]
		else:
			push_error("Reached end of file")
			return ""
	func move_back() -> String:
		if current_index -1 >= 0:
			current_index -= 1
			return text[current_index]
		else:
			push_error("Reached start of file")
			return ""
	func look_fw() -> String:
		if !is_at_end():
			return text[current_index + 1]
		else:
			push_error("Reached end of file")
			return ""
	func get_current() -> String:
		return text[current_index]

class Token:
	var type: String
	var value
	
	func _init(_type: String, _value) -> void:
		self.type = _type
		self.value = _value

func get_file(file_path: String) -> String:
	if !FileAccess.file_exists(file_path):
		push_error("Invalid file path")
		return ""
	var file = FileAccess.open(file_path, FileAccess.READ)
	var script = file.get_as_text()
	file.close()
	return script

func get_tokens(path: String) -> Array[Token]:
	var tokens: Array[Token]
	var text = get_file(path)
	var script = ScriptFile.new(text)
	tokens.append(Token.new(TOKENTYPES.START_OF_FILE, ""))
	while !script.is_at_end():
		var chara := script.get_current()
		if chara == " ":
			pass
		elif chara == "\n":
			tokens.append(Token.new(TOKENTYPES.NEWLINE, ""))
			var cur_indent := 0
			while script.look_fw() == "\t":
				cur_indent += 1
				script.move_fw()
			var empty: bool = script.look_fw() in [" ", "\n"]
			if not empty:
				if script.current_indent == cur_indent:
					pass
				elif script.current_indent > cur_indent:
					for i in range(script.current_indent - cur_indent):
						script.current_indent -= 1
						tokens.append(Token.new(TOKENTYPES.ENDBLOCK, ""))
				else:
					push_error("Invalid indentation at %s" % script.current_index)
		elif chara == "\"":
			tokens.append(Token.new(TOKENTYPES.STRING_LITERAL, get_string_literal(script)))
		elif chara == ":":
			script.current_indent += 1
			tokens.append(Token.new(TOKENTYPES.BEGINBLOCK, ""))
		elif chara.is_valid_ascii_identifier():
			tokens.append(get_symbol(script))
		script.move_fw()
	return tokens

func get_symbol(script: ScriptFile) -> Token:
	var value := script.get_current()
	while !script.is_at_end():
		var chara := script.move_fw()
		if symbol_regex.search(chara):
			value += chara
		elif chara in ["	", " ", "\n", "\r", ":"]:
			script.move_back()
			break
		else:
			push_error("found unexpected symbol: %s at %s" % [chara, script.current_index])
			return Token.new("", "")
	if value in COMMANDS.values():
		return Token.new(TOKENTYPES.COMMAND, value)
	elif value in CONDITIONALS.values():
		return Token.new(TOKENTYPES[value.to_upper()], "")
	elif value in [CHOICE_KEYWORD]:
		return Token.new(TOKENTYPES[value.to_upper()], "")
	else:
		return Token.new(TOKENTYPES.SYMBOL, value)

func get_string_literal(script: ScriptFile) -> String:
	var chara := script.move_fw()
	var value := ""
	while !script.is_at_end():
		if chara == "\"":
			value = value.c_unescape()
			return value
		value += chara
		chara = script.move_fw()
	push_error("Reached end of file and couldn't find the end of the string")
	return ""
