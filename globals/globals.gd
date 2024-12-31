extends Node
# Здесь будут храниться глобальные переменные

# Путь к файлу сохранения
var save_path = "user://savegame.save"

# текущий уровень (локация) на котором находится игрок
var current_level: String

# уровни (локации)
var level_1 = "res://scenes/levels/level_1.tscn"
var level_2 = "res://scenes/levels/level_2.tscn"

# Названия уровней локаций
var level_names: Dictionary = {
	level_1 : "Уровень 1",
	level_2 : "Уровень 2"
}

# уязвим ли игрок
var is_player_vulnerable: bool = true

# Может ли игрок сохранить игру (т.е. рядом ли он с сейв-поинтом)
var player_can_save: bool = false

# Может ли игрок двигаться
var player_can_move: bool = true

# Может ли игрок перейти на следующий уровень
var player_can_go_next_level: bool = false
# На какой именно уровень он может перейти
var next_level_path: String

# Переключение белого цвета спрайта игрока (при получении урона/конце неуязвимости)
signal switch_player_white_color

# Обновление интерфейса
signal ui_stat_change

# Включение/выключение меню паузы
signal pause_menu_switch

# UI показывает подсказку с текстом hint_text
signal ui_show_hint(hint_text : String)
# UI скрывает подсказку
signal ui_hide_hint()

# UI показывает сообщение с текстом message_text
signal ui_show_message(message_text: String)

# Находится ли игра на паузе
var is_pause: bool = false:
	set(value):
		is_pause = value
		get_tree().paused = value
		pause_menu_switch.emit()

# Здоровье игрока
var max_player_health: float
var player_health: float:
	set(value):
		if value > player_health:
			player_health = min(value, max_player_health)
		else:
			if is_player_vulnerable:
				player_health = value
				is_player_vulnerable = false
				PlayerInvulnerabilityTimer.start()
				switch_player_white_color.emit()
		stat_change()


func _ready() -> void:
	# Этот скрипт обрабатывается всегда независимо от паузы
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Подключаем сигнал глобального таймера PlayerInvulnerabilityTimer
	PlayerInvulnerabilityTimer.connect("player_vulnerable", player_vulnerable)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		is_pause = not is_pause
	# Различные интеракции
	if not is_pause:
		# Сохранение игры на костре
		if Input.is_action_just_pressed("interact") and player_can_save:
			save_game()
			show_message("Игра сохранена")
		# Переход на другой уровень
		elif Input.is_action_just_pressed("interact") and player_can_go_next_level:
			# При загрузке уровня через интеракцию узлы имеют стандартные значения свойств
			nodes_take_data_from_globals = false
			change_scene(next_level_path)

func player_vulnerable() -> void:
	is_player_vulnerable = true
	switch_player_white_color.emit()

# Выход из игры
func quit_game() -> void:
	get_tree().quit()

# Переключение сцены
func change_scene(scene_path : String) -> void:
	get_tree().change_scene_to_file(scene_path)
	is_pause = false
	player_can_move = true
	
# Обновляем интерфейс
func stat_change() -> void:
	ui_stat_change.emit()

# Показываем игроку подсказку с определённым текстом
func show_hint(hint_text: String) -> void:
	ui_show_hint.emit(hint_text)

# Скрываем подсказку
func hide_hint() -> void:
	ui_hide_hint.emit()

# Показываем сообщение с определённым текстом
func show_message(message_text:String) -> void:
	ui_show_message.emit(message_text)

signal ui_mode_switch
# Переключаем режим UI (normal_mode/movie_mode)
func switch_ui_mode() -> void:
	ui_mode_switch.emit()

signal camera_zoom()
# Увеличиваем масштаб камеры
func zoom_camera() -> void:
	camera_zoom.emit()

signal camera_zoom_out()
# Уменьшаем масштаб камеры
func zoom_out_camera() -> void:
	camera_zoom_out.emit()

# Данные узла игрока для сохранения
var player_data: Dictionary
# Получить данные узла игрока
signal get_player_data

# Если значение этой переменной - true, то при загрузке новой сцены определённые
# узлы будут брать значения для некоторых своих свойств из globals
# Это нужно для загрузки сохранённых об узлах данных
var nodes_take_data_from_globals: bool = false

# Сохраняем прогресс игры
func save_game() -> void:
	# Открываем файл сохранения на запись
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	# Сохраняем всё что нужно
	file.store_var(current_level)
	file.store_var(max_player_health)
	file.store_var(player_health)
	
	get_player_data.emit()
	file.store_var(player_data)

# Загружаем ранее сохранённую игру
func load_game() -> void:
	# Проверяем, существует ли файл сохранения
	if not FileAccess.file_exists(save_path):
		print("Ошибка, файла сохранения не существует")
		return
	# Открываем файл сохранения на чтение
	var file = FileAccess.open(save_path, FileAccess.READ)
	# Получаем сохранённые данные
	current_level = file.get_var()
	max_player_health = file.get_var()
	player_health = file.get_var()
	
	player_data = file.get_var()
	
	# Узлы берут значения из globals
	nodes_take_data_from_globals = true
	
	# Загружаем сцену, которая была в файле сохранения
	change_scene(current_level)

# Начинаем новую игру, все глобальные игровые переменные возвращаются к начальным значениям
func new_game() -> void:
	current_level = level_1              # Начальный уровень
	max_player_health = 300              # Начальное макс. здоровье
	player_health = max_player_health    # Начальное здоровье
	nodes_take_data_from_globals = false # У всех узлов значения по умолчанию
	# Загружаем первую сцену
	change_scene(current_level)
