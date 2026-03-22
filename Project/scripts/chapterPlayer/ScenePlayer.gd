extends Node
class_name Interpreter



signal scene_finished
signal scene_requested
signal transition_finished
signal next_requested

enum STATES {
	WAITING_ANIM,
	SHOWING,
	IDLE,
	WAITING_INPUT,
}

var cur_state: STATES = STATES.IDLE

const KEY_EOS := -1
const KEY_RESTART_SCENE := -2

var _scene_data := {}


@onready var textbox: textcontroller = $CanvasLayer/textbox
@onready var characters: CharacterDisplayer = $Character
@onready var background: bgDisplayer = $Background


func run_scene() -> void:
	var key = 0
	textbox.hide_everything()
	while key != KEY_EOS:
		var node: SceneOrganiser.BaseNode = _scene_data[key] if _scene_data.has(key) else null
		var character: Character
		cur_state = STATES.SHOWING
		if node is SceneOrganiser.BackgroundNode:
			var bground: Background = ResourceDB.get_background(node.bg)
			var anim: String = node.transition
			background.display_bg(bground, anim)
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
		elif node is SceneOrganiser.WaitCommandNode:
			match node.value:
				Lexer.COMMANDS.WAIT_ANIM:
					cur_state = STATES.WAITING_ANIM
				Lexer.COMMANDS.WAIT_INPUT:
					cur_state = STATES.WAITING_INPUT
			key = node.next
			await next_requested
		else:
			cur_state = STATES.IDLE
			key = KEY_EOS
	scene_finished.emit()

func load_scene(dialogue: SceneOrganiser.DialogueTree) -> void:
	_scene_data = dialogue.nodes


func _on_inputcontroller_requested() -> void:
	match cur_state:
		STATES.SHOWING:
			textbox.finish()
		STATES.WAITING_INPUT:
			next_requested.emit()


func _on_background_anim_finished() -> void:
	if cur_state == STATES.WAITING_ANIM:
		cur_state = STATES.SHOWING
		next_requested.emit()


func _on_character_display_finished() -> void:
	if cur_state == STATES.WAITING_ANIM:
		cur_state = STATES.SHOWING
		next_requested.emit()
