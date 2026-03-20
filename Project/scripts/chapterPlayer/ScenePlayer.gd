extends Node
class_name Interpreter



signal scene_finished
signal scene_requested
signal transition_finished

const KEY_EOS := -1
const KEY_RESTART_SCENE := -2

var _scene_data := {}


@onready var textbox: textcontroller = $CanvasLayer/textbox
@onready var characters: CharacterDisplayer = $Character
@onready var background := $Background


func run_scene() -> void:
	var key = 0
	while key != KEY_EOS:
		var node: SceneOrganiser.BaseNode = _scene_data[key] if _scene_data.has(key) else null
		var character: Character
		if node is SceneOrganiser.BackgroundNode:
			var bground: Background = ResourceDB.get_background(node.bg)
			background.texture = bground.texture
			key = node.next
		elif node is SceneOrganiser.CharacterCommandNode:
			character = ResourceDB.get_character(node.character_id) if node.character_id != "" else ResourceDB.get_narrator()
			var side: String = node.side if "side" in node else "left"
			var animation: String = node.animation
			var expression: String = node.expression
			characters._display(character, side, expression, animation)
			key = node.next
		elif node is SceneOrganiser.DialogueNode:
			if "line" in node:
				var char_name: String
				if "character" in node:
					char_name = node.character
					if char_name.contains("_"):
						char_name = char_name.replace("_", " ")
				textbox.change_text(node.line, false, char_name)
				key = node.next
				await textbox.next_requested
		elif node is SceneOrganiser.JumpCommand:
			key = node.next - 1
		else:
			key = KEY_EOS
	scene_finished.emit()

func load_scene(dialogue: SceneOrganiser.DialogueTree) -> void:
	_scene_data = dialogue.nodes


func _on_inputcontroller_requested() -> void:
	textbox.finish()
