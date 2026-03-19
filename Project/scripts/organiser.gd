@tool
extends Resource
class_name  SceneOrganiser

#This is where the choices and conditionals will be stored
#the numbers are so big so as to not be normally reached
#to group them in the dialoguetree more easily
const CHOICE_ID := 1000000000
const CONDITIONAL_ID := 2100000000

#a list of jump points that direct to a specific node in the tree
var _jump_points := {}
var jump_points_set: bool = false

class DialogueTree:
	var nodes := {}
	var index := 0
	
	func append_node(node: BaseNode) -> void:
		nodes[index] = node
		index += 1

class BaseNode:
	var next: int
	func _init(_next: int) -> void:
		self.next = _next

class SetCommandNode:
	extends BaseNode
	
	var symbol: String
	var value
	
	func _init(_next: int, _symbol: String, _value) -> void:
		self.next = _next
		self.symbol = _symbol
		self.value = _value

class CharacterCommandNode:
	extends BaseNode
	
	var character_id: String
	var animation: String
	var expression: String
	var side: String
	
	func _init(_next: int, _character: String) -> void:
		self.next = _next
		self.character_id = _character

class SceneCommandNode:
	extends BaseNode
	
	var scene: String
	
	func _init(_next: int, _scene: String) -> void:
		self.next = _next
		self.scene = _scene

class DialogueNode:
	extends BaseNode
	
	var line: String
	var character: String

	
	func _init(_next: int, _line: String) -> void:
		self.line = _line
		self.next = _next

class BackgroundNode:
	extends BaseNode
	var bg: String
	var transition: String
	
	func _init(_next: int, _bg: String) -> void:
		self.next = _next
		self.bg = _bg
		

class TransitionCommandNode:
	extends BaseNode
	
	var transition: String
	
	func _init(_next: int, _transition: String) -> void:
		self.next = _next
		self.transition = _transition

class ConditionalBlock:
	extends BaseNode
	
	var condition: Parser.BaseExpression
	
	func _init(_next: int, _condition: Parser.BaseExpression) -> void:
		self.next = _next
		self.condition = _condition

class ConditionalTreeNode:
	extends BaseNode
	
	var if_block: ConditionalBlock
	var elif_blocks: Array
	var else_block: ConditionalBlock
	
	func _init(_next: int, _if_block: ConditionalBlock) -> void:
		self.next = _next
		self.if_block = _if_block

class PassCommandNode:
	extends BaseNode
	
	func _init(_next: int) -> void:
		self.next = _next

class JumpCommand:
	extends BaseNode
	
	var jump_point: String
	
	func _init(_next: int) -> void:
		self.next = _next

func organise(syntax_tree: Parser.SyntaxTree, start_index: int) -> DialogueTree:
	var dialogue_tree := DialogueTree.new()
	dialogue_tree.index = start_index
	if !jump_points_set:
		set_jump_points(syntax_tree, dialogue_tree)
	while !syntax_tree.is_at_end():
		var expression: Parser.BaseExpression = syntax_tree.move_fw()
		if expression.type == Parser.EXPRESSIONTYPES.COMMAND:
			var node := transpile_command(dialogue_tree, expression)
			dialogue_tree.append_node(node)
		elif expression.type == Parser.EXPRESSIONTYPES.DIALOGUE:
			var node := transpile_dialogue(dialogue_tree, expression)
			dialogue_tree.append_node(node)
		
		elif expression.type == Parser.EXPRESSIONTYPES.CONDITIONALTREE:
			if expression.if_expression == null:
				push_error("Invalid conditional tree")
				continue
			var original_value := dialogue_tree.index
			dialogue_tree.index += CONDITIONAL_ID + 1
			var tree_node = ConditionalTreeNode.new(original_value + 1, ConditionalBlock.new(dialogue_tree.index, expression.if_expression.value.front()))
			var if_subtree := Parser.SyntaxTree.new()
			if_subtree.values = expression.if_expression.block
			var if_block_dialogue_tree: DialogueTree = organise(if_subtree, dialogue_tree.index)
			_copy_nodes(original_value, if_block_dialogue_tree.nodes.keys(), dialogue_tree, if_block_dialogue_tree)
			if not expression.elif_block.is_empty():
				var elif_blocks := []
				for elif_block in expression.elif_block:
					var elif_subtree := Parser.SyntaxTree.new()
					elif_subtree. values = elif_block.block
					var elif_block_dialogue_tree: DialogueTree = organise(elif_subtree, dialogue_tree.index)
					elif_blocks.append(ConditionalBlock.new(dialogue_tree.index, elif_block.value.front()))
					_copy_nodes(original_value, elif_block_dialogue_tree.nodes.keys(), dialogue_tree, elif_block_dialogue_tree)
				tree_node.elif_blocks = elif_blocks
			if expression.else_expression != null:
				var else_subtree := Parser.SyntaxTree.new()
				else_subtree.values = expression.else_expression.block
				
				var else_block_dialogue_tree: DialogueTree = organise(else_subtree, dialogue_tree.index)
				tree_node.else_block = ConditionalBlock.new(dialogue_tree.index, null)
				_copy_nodes(original_value, else_block_dialogue_tree.nodes.keys(), dialogue_tree, else_block_dialogue_tree)
			dialogue_tree.index = original_value
			dialogue_tree.append_node(tree_node)
		else:
			push_error("Unrecognized expression of type: %s with value: %s" % [expression.type, expression.value])
	return dialogue_tree

func transpile_command(tree: DialogueTree, expression: Parser.BaseExpression) -> BaseNode:
	var command_node: BaseNode = null
	
	if expression.value == Lexer.COMMANDS.BACKGROUND:
		var background: String = expression.arguments[0].value
		
		command_node = BackgroundNode.new(tree.index + 1, background)
		command_node.transition = expression.arguments[1].value

	elif expression.previous_type == Lexer.COMMANDS.CHARACTER:
		command_node = CharacterCommandNode.new(tree.index + 1, expression.arguments[0].value)
		var length := len(expression.arguments)
		command_node.expression = expression.arguments[1].value if length > 1 else ""
		command_node.animation = expression.arguments[2].value if length > 2 else ""
		command_node.side = expression.arguments[3].value if length > 3 else ""

	elif expression.value == Lexer.COMMANDS.SCENE:
		var new_scene: String = expression.arguments[0].value
		command_node = SceneCommandNode.new(tree.index + 1, new_scene)
	elif expression.value == Lexer.COMMANDS.JUMP:
		print("jump maybe")
		var jump_point: String = expression.arguments[0].value
		if _jump_points.has(jump_point):
			var target: int = _get_jump_point(jump_point)
			command_node = JumpCommand.new(target)
			print("jump found")
	elif expression.value == Lexer.COMMANDS.SET:
		var symbol: String = expression.arguments[0].value
		var value = expression.arguments[1].value
		command_node = SetCommandNode.new(tree.index + 1, symbol, value)
	
	return command_node

func transpile_dialogue(dialogue_tree: DialogueTree, expression: Parser.BaseExpression) -> DialogueNode:
	var node := DialogueNode.new(dialogue_tree.index + 1, expression.value)
	node.character = expression.character
	return node
	#node.character = (
		#expression.arguments[0].value if not expression.arguments.is_empty() else ""
	#)
	#
	#var length := len(expression.arguments)
	#node.expression = expression.arguments[1].value if length > 1 else ""
	#node.animation = expression.arguments[2].value if length > 2 else ""
	#node.side = expression.arguments[3].value if length > 3 else ""
	#return node


func set_jump_points(tree: Parser.SyntaxTree, dialogue_tree: DialogueTree) -> void:
	var original_index = tree.current_index
	var dialogue_og_index = dialogue_tree.index
	while !tree.is_at_end():
		var expression = tree.move_fw()
		if expression.value == Lexer.COMMANDS.MARK:
			var new_jump_point: String = expression.arguments[0].value
			if !_jump_points.has(new_jump_point):
				_add_jump_point(new_jump_point, dialogue_tree.index)
	tree.current_index = original_index
	dialogue_tree.index = dialogue_og_index
	jump_points_set = true

func _add_jump_point(name: String, index: int) -> void:
	if _jump_points.has(name):
		push_error("Jump point %s already exists" % name)
		return
	print("added jump point %s that points to %s" % [name, index])
	_jump_points[index] = name

func _copy_nodes(original_value: int, nodes: Array, target_tree: DialogueTree, source_tree: DialogueTree) -> void:
	source_tree.append_node(PassCommandNode.new(original_value + 1))
	nodes.append(source_tree.nodes.keys().back())
	for node in nodes:
		target_tree.nodes[node] = source_tree.nodes[node]
		target_tree.index += 1

func _get_jump_point(name: String) -> int:
	if _jump_points.has(name):
		return _jump_points[name]
	push_error("Nonexistent jump point")
	return -2
