extends Node
# Здесь будут храниться глобальные переменные

# Путь к файлу сохранения
var save_path = "user://savegame.save"

# текущий уровень (локация) на котором находится игрок
var current_level: String

# уровни (локации)
var level_1 = "res://scenes/levels/level_1.tscn"

# уязвим ли игрок
var is_player_vulnerable: bool = true

# Может ли игрок сохранить игру (т.е. рядом ли он с сейв-поинтом)
var player_can_save: bool = false

# Стартовая позиция игрока на уровне (локации)
var start_player_pos: Vector2
# Получить текущую позицию игрока в start_player_pos
signal get_player_pos()

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
		if Input.is_action_just_pressed("interact") and player_can_save:
			save_game()
			show_message("Игра сохранена")

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


# Сохраняем прогресс игры
func save_game() -> void:
	# Открываем файл сохранения на запись
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	# Сохраняем всё что нужно
	file.store_var(current_level)
	file.store_var(max_player_health)
	file.store_var(player_health)
	
	get_player_pos.emit()
	file.store_var(start_player_pos)
	

# Загружаем ранее сохранённую игру
func load_game() -> void:
	# Проверяем, существует ли файл сохранения
	if FileAccess.file_exists(save_path):
		# Открываем файл сохранения на чтение
		var file = FileAccess.open(save_path, FileAccess.READ)
		# Получаем сохранённые данные
		current_level = file.get_var()
		max_player_health = file.get_var()
		player_health = file.get_var()
		
		start_player_pos = file.get_var()
	
		# Загружаем сцену, которая была в файле сохранения
		change_scene(current_level)

# Начинаем новую игру, все глобальные игровые переменные возвращаются к начальным значениям
func new_game() -> void:
	current_level = level_1
	max_player_health = 300
	player_health = max_player_health
	start_player_pos = Vector2.ZERO
	# Загружаем первую сцену
	change_scene(current_level)
