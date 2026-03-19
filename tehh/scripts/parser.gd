@tool
extends Resource
class_name Parser


const EXPRESSIONTYPES := {
	DIALOGUE = "dialogue",
	CONDITIONALTREE = "conditional_tree",
	IF = Lexer.CONDITIONALS.IF,
	ELIF = Lexer.CONDITIONALS.ELIF,
	ELSE = Lexer.CONDITIONALS.ELSE,
	COMMAND = Lexer.TOKENTYPES.COMMAND,
	CHARACTER = Lexer.COMMANDS.CHARACTER,
}


func parse_tokens(tokens: Array[Lexer.Token]) -> SyntaxTree:
	var tree := SyntaxTree.new()
	var parser := MiniParser.new(tokens)
	while not parser.is_at_end():
		var expression := parser.parse_next_token()
		if expression:
			tree.append_expression(expression)
	return tree

class BaseExpression:
	var type : String
	var value
	
	func _init(_type: String, _value) -> void:
		self.type = _type
		self.value = _value

class DialogueExpression:
	extends BaseExpression
	
	var character: String
	
	func _init(_type: String, _value, _character: String) -> void:
		self.type = _type
		self.character = _character
		self.value = _value

class FunctionExpression:
	extends BaseExpression
	var arguments := []
	var previous_type: String
	
	func _init(_type: String, _value, _arguments: Array, _prev_type: String) -> void:
		self.type = _type
		self.value = _value
		self.arguments = _arguments
		self.previous_type = _prev_type

class ConditionalExpression:
	extends BaseExpression
	
	var block := []
	
	func _init(_type: String, _value, _block: Array) -> void:
		self.type = _type
		self.value = _value
		self.block = _block
		
	

class ConditionalTree:
	extends BaseExpression
	
	var if_expression: ConditionalExpression
	var elif_block := []
	var else_expression: ConditionalExpression
	
	func _init(_type: String, _value, _if: ConditionalExpression, _elif_block: Array, _else: ConditionalExpression) -> void:
		super(type, value)
		self.if_expression = _if
		self.elif_block = _elif_block
		self.else_expression = _else

class MiniParser:
	var tokens := []
	var index := -1 #same as with the syntaxtree
	
	func _init(_tokens: Array) -> void:
		self.tokens = _tokens
	
	func move_fw() -> Lexer.Token:
		if !is_at_end():
			index += 1
			return tokens[index]
		push_error("Is at the end of the token list")
		return null
	
	func move_back() -> Lexer.Token:
		if self.index > 0:
			index -=1
			return tokens[index]
		push_error("Is at the start of the token list")
		return null
	
	func look_back() -> Lexer.Token:
		if self.index > 0:
			return self.tokens[self.index - 1]
		return null
	
	func get_current()  -> Lexer.Token:
		return tokens[index]
	
	func look_fw() -> Lexer.Token:
		if !is_at_end():
			return tokens[index + 1]
		push_error("Is at the end of the token list")
		return null
	
	func is_at_end() -> bool:
		return index == len(tokens) -1
	
	func find_until(expression_type: String) -> Array:
		var arguments: Array
		while !self.is_at_end() and self.look_fw().type != expression_type:
			var argument := self.parse_next_token()
			if argument:
				arguments.append(argument)
		return arguments
	
	
	func parse_indented_block() -> Array:
		var block := []
		var indent := 1
		if self.get_current().type == Lexer.TOKENTYPES.BEGINBLOCK:
			self.move_fw()
		while !is_at_end():
			var next_expression := self.parse_next_token()
			if next_expression == null:
				continue
			elif next_expression.type == Lexer.TOKENTYPES.BEGINBLOCK:
				indent += 1
				block.append(self.parse_indented_block())
			elif next_expression.type == Lexer.TOKENTYPES.ENDBLOCK:
				indent -= 1
				if indent == 0:
					return block
				else:
					push_error("something failed")
					break
			else:
				block.append(next_expression)
			
		return []
	
	func parse_next_token() -> BaseExpression:
		var cur_token := self.move_fw()
		if cur_token.type in [Lexer.TOKENTYPES.SYMBOL, Lexer.TOKENTYPES.STRING_LITERAL]:
			if cur_token.type == Lexer.TOKENTYPES.STRING_LITERAL:
				return DialogueExpression.new(EXPRESSIONTYPES.DIALOGUE, cur_token.value, "")
			else:
				if self.look_fw() and self.look_fw().type == Lexer.TOKENTYPES.STRING_LITERAL:
					return DialogueExpression.new(EXPRESSIONTYPES.DIALOGUE, parse_next_token().value, cur_token.value)
				return BaseExpression.new(cur_token.type, cur_token.value)
		elif cur_token.type == Lexer.TOKENTYPES.COMMAND:
			var args := self.find_until(Lexer.TOKENTYPES.NEWLINE)
			return FunctionExpression.new(EXPRESSIONTYPES.COMMAND, cur_token.type, args, cur_token.value)
		
		elif cur_token.type == Lexer.CONDITIONALS.IF:
			var IF := ConditionalExpression.new(EXPRESSIONTYPES.IF, self.find_until(Lexer.TOKENTYPES.ENDBLOCK), parse_indented_block())
			var ELIF_BLOCK := []
			while self.look_fw().type == Lexer.CONDITIONALS.ELIF:
				ELIF_BLOCK.append(ConditionalExpression.new(EXPRESSIONTYPES.ELIF, self.find_until(Lexer.TOKENTYPES.ENDBLOCK), parse_indented_block()))
			var ELSE: ConditionalExpression
			if self.look_fw().type == Lexer.CONDITIONALS.ELSE:
				self.move_fw()
				ELSE = ConditionalExpression.new(
					EXPRESSIONTYPES.ELSE,
					null,
					parse_indented_block()
				)
			return ConditionalTree.new(
				EXPRESSIONTYPES.CONDITIONALTREE,
				"",
				IF,
				ELIF_BLOCK,
				ELSE
			)
		
		elif (cur_token.type in 
		[Lexer.TOKENTYPES.SYMBOL, 
		Lexer.TOKENTYPES.STRING_LITERAL,
		Lexer.TOKENTYPES.BEGINBLOCK,
		Lexer.TOKENTYPES.ENDBLOCK
		]):
			return BaseExpression.new(cur_token.type, cur_token.value)
		else:
			return null
class SyntaxTree:
	var expressions := []
	var current_index := -1 #apparently starting in -1 solves some problems
	
	func append_expression(expression: BaseExpression) -> void:
		self.expressions.append(expression)
	
	func move_fw() -> BaseExpression:
		if !is_at_end():
			current_index += 1
			return expressions[current_index]
		else:
			push_error("Is at the end of the expression list")
			return null
	
	func look_fw() -> BaseExpression:
		if !is_at_end():
			return expressions[current_index + 1]
		else:
			push_error("Is at the end of the expression list")
			return null
	
	func is_at_end() -> bool:
		return current_index == len(expressions) - 1
	
