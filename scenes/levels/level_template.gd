extends Node2D
class_name LevelTemplate

# Словарь эффектов (упакованные сцены)
const effects: Dictionary = {
	"dash_effect" : preload("res://scenes/effects/dash_effect.tscn"),
	"air_dash_effect" : preload("res://scenes/effects/air_dash_effect.tscn"),
	"double_jump_effect" : preload("res://scenes/effects/double_jump_effect.tscn"),
	"teleport_effect" : preload("res://scenes/effects/teleport_effect.tscn"),
	"health_up_effect" : preload("res://scenes/effects/health_up_effect.tscn"),
	"ball_effect" : preload("res://scenes/effects/ball_effect.tscn")
}

# Массив фонов
const backgrounds: Array = [
	preload("res://scenes/background/bg.tscn"),
	preload("res://scenes/background/bg_2.tscn")
]
# Какой индекс фона у этого уровня (в массиве backgounds)
@export_range(0, len(backgrounds) - 1) var background_num: int

# Название уровня
var level_name: String

# Файловый путь до уровня
var level_path: String

func _ready() -> void:
	level_path = get_tree().current_scene.scene_file_path
	level_name = Globals.level_names[level_path]
	Globals.current_level = level_path
	Globals.connect("create_new_effect", create_new_effect)
	# Добавляем фон в уровень
	add_child(backgrounds[background_num].instantiate())

# Создание нового эффекта на уровне
# effect - имя эффекта (ключ в словаре эффектов effects)
# pos - где создаём эффект
# flip_hor - нужно ли отражать эффект по горизонтали
func create_new_effect(effect: String, pos: Vector2, flip_hor: bool, effect_rotation: float) -> void:
	# Создаём экземпляр эффекта
	var new_effect = effects[effect].instantiate()
	# Задаём ему позицию
	new_effect.global_position = pos
	# Отражаем его по горизонтали если требуется
	new_effect.flip_h = flip_hor
	# Поворачиваем эффект
	new_effect.rotate(effect_rotation)
	# Добавляем его в узел эффектов
	$Effects.add_child(new_effect)
