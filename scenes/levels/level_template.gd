extends Node2D

# Название уровня
var level_name: String

# Файловый путь до уровня
var level_path: String

func _ready() -> void:
	level_path = get_tree().current_scene.scene_file_path
	level_name = Globals.level_names[level_path]
	Globals.current_level = level_path
	
