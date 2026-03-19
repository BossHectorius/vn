extends Node
class_name ChapterPlayer

@export_category("Scripts")
##the list of scenes to be played, in order. You must input the file path of the .txt file (the scene).
@export var scripts: Array[String] = []



var current_index: int

var scenes := []

@onready var scene_player: Interpreter = $ScenePlayer


func _ready() -> void:
	get_scenes()
	_play_scene(0)


func change_scene_player(dialogue_tree_new: SceneOrganiser.DialogueTree) -> void:
	scene_player.load_scene(dialogue_tree_new)

func get_scenes() -> void:
	var lexer := Lexer.new()
	var parser := Parser.new()
	var organiser := SceneOrganiser.new()
	if !scripts.is_empty():
		for script in scripts:
			var tokens: Array = lexer.get_tokens(script)
			var tree: Parser.SyntaxTree = parser.parse_tokens(tokens)
			for i in tree.expressions:
				print(i.type)
			var dialogue: SceneOrganiser.DialogueTree = organiser.organise(tree, 0)
			if !dialogue.nodes[dialogue.index - 1] is SceneOrganiser.JumpCommand:
				(dialogue.nodes[dialogue.index - 1] as SceneOrganiser.BaseNode).next = - 1
			scenes.append(dialogue)



func _play_scene(index: int) -> void:
	current_index = int(clamp(index, 0, scenes.size()))
	var scene = scenes[current_index]
	print(scene)
	scene_player.load_scene(scene)
	scene_player.run_scene()
	



func _on_scene_player_scene_finished() -> void:
	if current_index == scenes.size() - 1:
		return
	_play_scene(current_index+1)
