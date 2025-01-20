extends Node
# Здесь будут храниться глобальные переменные

# Путь к файлу сохранения
var save_path = "user://savegame.save"

# Главное меню
const MAIN_MENU = "res://scenes/UI/main_menu.tscn"

# текущий уровень (локация) на котором находится игрок
var current_level: String = MAIN_MENU

# уровни (локации)
# Тестировочные локации (для тестирования разных механик)
var test_level_1 = "res://scenes/levels/level_1.tscn"
var test_level_2 = "res://scenes/levels/level_2.tscn"
# Уровни для практического применения механик
# Некоторые механики должны попасть в "Feather of Destiny"
var introductory_level = "res://scenes/levels/introductory_level.tscn"
var cave_level = "res://scenes/levels/cave_level.tscn"
var magic_forest_level = "res://scenes/levels/magic_forest.tscn"
var dangeon_level = "res://scenes/levels/dangeon.tscn"

# Названия уровней локаций
var level_names: Dictionary = {
	test_level_1 : "Тест-ровень 1",
	test_level_2 : "Тест-уровень 2",
	introductory_level : "Начало",
	cave_level : "Пещера",
	magic_forest_level : "Магический лес",
	dangeon_level : "Подземелье"
}

# Позиция игрока на следующем уровне
# (Если null, то будет позиция, заданная в сцене уровня)
var player_next_level_position = null

# уязвим ли игрок
var is_player_vulnerable: bool = true

# Может ли игрок переключить рычаг
var player_can_switch_lever = false
signal switch_lever
# Какой рычаг может переключить игрок (Путь до этого рычага)
var lever_path

# Может ли игрок сохранить игру (т.е. рядом ли он с сейв-поинтом)
var player_can_save: bool = false

# Может ли игрок двигаться
var player_can_move: bool = true

# Может ли игрок перейти на следующий уровень
var player_can_go_next_level: bool = false
# На какой именно уровень он может перейти
var next_level_path: String

# Умер ли персонаж игрока
var does_player_died: bool = false

# Информация о диалогах
var dialogue_info: Dictionary = {
	"player_can" : false,    # Может ли игрок сейчас начать диалог
	"npс" : null             # С каким НПС игрок может начать диалог
}

signal on_black_color_player
signal off_black_color_player

# В зонах видимости скольки врагов сейчас находится игрок
var count_enemies_sees_player: int = 0
# Скрывается ли сейчас игрок
var player_stealth: bool = false:
	set(value):
		player_stealth = value
		if value:
			on_black_color_player.emit()
		else:
			off_black_color_player.emit()
	
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
# Здесь указано значение для тестирования уровней
# (Оно обновится при начале новой игры/загрузке сохранения)
var max_player_health: float = 1000
var player_health: float = max_player_health:
	set(value):
		# Здоровье игрока нельзя изменять если персонаж игрока умер
		if does_player_died:
			return
		if value > player_health:
			player_health = min(value, max_player_health)
			# Обновляем данные об игроке в глобальном скрипте (в т.ч. о его позиции)
			get_player_data.emit()
			# Получаем позицию игрока (Если она есть в словаре)
			var player_pos = Vector2.ZERO
			if player_data.has("global_position"):
				player_pos = player_data["global_position"]
			# Создаём эффект восстановления здоровья там, где стоит игрок
			create_effect("health_up_effect", player_pos + Vector2(0, -10))
		# Если value = 0, то ничего не происходит
		elif value < player_health:
			if is_player_vulnerable:
				player_health = max(value, 0)
				is_player_vulnerable = false
				PlayerInvulnerabilityTimer.start()
				switch_player_white_color.emit()
				# Смерть персонажа игрока
				if player_health == 0:
					player_death()
		stat_change()


signal player_died
func player_death() -> void:
	does_player_died = true
	# Сообщаем узлу игрока что персонаж погиб
	player_died.emit()
	# обездвиживаем игрока
	player_can_move = false
	# Ждём немного времени (с учетом паузы, поэтому process_always=false)
	await get_tree().create_timer(5, false).timeout
	# Загружаем последнее сохранение, если состояние персонажа всё ещё "умер"
	# т.е. если игрок сам не перешёл в другую сцену через меню паузы
	if does_player_died:
		load_game()

func _ready() -> void:
	# Этот скрипт обрабатывается всегда независимо от паузы
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Подключаем сигнал глобального таймера PlayerInvulnerabilityTimer
	PlayerInvulnerabilityTimer.connect("player_vulnerable", player_vulnerable)

func _process(_delta: float) -> void:
	# Если игрок не в главном меню и нажимает esc, то он либо переключает паузу,
	# либо выходит из диалога (если он в диалоге)
	if Input.is_action_just_pressed("esc") and current_level != MAIN_MENU:
		if DialogueController.dialogue:
			DialogueController.dialogue_finish()
		else:
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
			# Сохраняемся перед тем как перейти на следующий уровень
			save_game()
			# Меняем сцену уровня
			change_scene(next_level_path)
		# Диалог с НПС
		elif Input.is_action_just_pressed("interact") and dialogue_info["player_can"]:
			# Если игрок уже в диалоге, то он из него выходит, иначе начинает
			if DialogueController.dialogue:
				DialogueController.dialogue_finish()
			else:
				DialogueController.dialogue_start(dialogue_info["npc"])
		# Переключение рычага
		elif Input.is_action_just_pressed("interact") and player_can_switch_lever:
			switch_lever.emit()

func player_vulnerable() -> void:
	is_player_vulnerable = true
	switch_player_white_color.emit()

# Выход из игры
func quit_game() -> void:
	get_tree().quit()

# Переключение сцены
func change_scene(scene_path : String) -> void:
	current_level = scene_path
	get_tree().change_scene_to_file(scene_path)
	# Устанавливаем некоторые глобальные переменные в стандартные значения
	is_pause = false
	player_can_move = true
	does_player_died = false
	count_enemies_sees_player = 0
	player_stealth = false
	
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
	
signal create_new_effect(effect: String, pos: Vector2, flip_hor: bool)
# Создать новый эффект на текущем уровне
func create_effect(effect: String, pos: Vector2, flip_hor: bool = false, effect_rotation: float = 0) -> void:
	create_new_effect.emit(effect, pos, flip_hor, effect_rotation)

# Данные узла игрока для сохранения
var player_data: Dictionary
# Получить данные узла игрока
signal get_player_data

# Если значение этой переменной - true, то при загрузке новой сцены определённые
# узлы будут брать значения для некоторых своих свойств из globals
# Это нужно для загрузки сохранённых об узлах данных
var nodes_take_data_from_globals: bool = false

# Информация о сохраняемых объектах (аптечки, зоны движения камеры, монетки и т.п.)
var objects_save_data: Dictionary

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
	
	file.store_var(objects_save_data)
	print(objects_save_data)

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
	# Узлы берут значения из globals
	nodes_take_data_from_globals = true
	# Загружаем сцену, которая была в файле сохранения
	change_scene(current_level)
	
	max_player_health = file.get_var()
	player_health = file.get_var()

	player_data = file.get_var()
	
	objects_save_data = file.get_var()
	print(objects_save_data)

# Начинаем новую игру, все глобальные игровые переменные возвращаются к начальным значениям
func new_game() -> void:
	current_level = introductory_level   # Начальный уровень
	max_player_health = 300              # Начальное макс. здоровье
	player_health = max_player_health    # Начальное здоровье
	nodes_take_data_from_globals = false # У всех узлов значения по умолчанию
	objects_save_data.clear()
	# "Обнуляем" позицию игрока
	player_data["global_position"] = Vector2.ZERO
	
	# Обновляем файл сохранения
	save_game()
	
	# Загружаем первую сцену
	change_scene(current_level)
