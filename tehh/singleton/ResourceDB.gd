extends Node

const NARRATOR_ID = "narrator"
@warning_ignore("unused_private_class_variable")
@onready var _characters := load_resources("res://Characters/", "_is_character")
@warning_ignore("unused_private_class_variable")
@onready var _backgrounds := load_resources("res://Backgrounds/", "_is_background")

func load_resources(folder_path: String, check_type_function: String) -> Dictionary:
	var directory := DirAccess.open(folder_path)
	if !directory:
		push_error("Invalid folder path or folder is empty")
		return {}
	
	var resources := {}
	directory.list_dir_begin()
	var filename = directory.get_next()
	while filename != "":
		if filename.ends_with(".tres"):
			var resource: Resource = load(folder_path.path_join(filename))
			if not call(check_type_function, resource):
				continue
			resources[resource.id] = resource
		filename = directory.get_next()
	directory.list_dir_end()
	return resources

func get_background(id: String) -> Background:
	return _backgrounds.get(id)

func get_character(id: String) -> Character:
	return _characters.get(id)

func get_narrator() -> Character:
	return _characters.get(NARRATOR_ID)

func _is_character(resource: Resource) -> bool:
	return resource is Character

func _is_background(resource: Resource) -> bool:
	return resource is Background
