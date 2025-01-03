extends Node2D

# Эффект от рывка (дым)
var dash_effect: PackedScene = preload("res://scenes/effects/dash_effect.tscn")
var air_dash_effect: PackedScene = preload("res://scenes/effects/air_dash_effect.tscn")

# Название уровня
var level_name: String

# Файловый путь до уровня
var level_path: String

func _ready() -> void:
	level_path = get_tree().current_scene.scene_file_path
	level_name = Globals.level_names[level_path]
	Globals.current_level = level_path

# Создаём эффект дыма
func _on_player_create_dash_effect(pos: Vector2, flip_hor: bool) -> void:
	# Создаём экземпляр сцены
	var new_dash_effect = dash_effect.instantiate()
	new_dash_effect.global_position = pos
	new_dash_effect.global_position.y += 9 # Немного смещаем его вниз к ногам персонажа игрока
	if flip_hor: # Смещаем дым немного назад от персонажа
		new_dash_effect.global_position.x -= 26
	else:
		new_dash_effect.global_position.x += 26
	new_dash_effect.flip_h = flip_hor
	$Effects.add_child(new_dash_effect)

# Эффект дыма в воздухе
func _on_player_create_air_dash_effect(pos: Vector2, flip_hor:bool) -> void:
	var new_air_dash_effect = air_dash_effect.instantiate()
	new_air_dash_effect.global_position = pos
	if flip_hor:
		new_air_dash_effect.global_position.x -= 14
	else:
		new_air_dash_effect.global_position.x += 14
	$Effects.add_child(new_air_dash_effect)
