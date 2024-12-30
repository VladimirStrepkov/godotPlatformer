extends Node
# Здесь будут храниться глобальные переменные

# уязвим ли игрок
var is_player_vulnerable: bool = true

# Переключение белого цвета спрайта игрока (при получении урона/конце неуязвимости)
signal switch_player_white_color

# Обновление интерфейса
signal stat_change

# Включение/выключение меню паузы
signal pause_menu_switch

# Находится ли игра на паузе
var is_pause: bool = false:
	set(value):
		is_pause = value
		get_tree().paused = value
		pause_menu_switch.emit()


func _ready() -> void:
	# Этот скрипт обрабатывается всегда независимо от паузы
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Подключаем сигнал глобального таймера PlayerInvulnerabilityTimer
	PlayerInvulnerabilityTimer.connect("player_vulnerable", player_vulnerable)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		is_pause = not is_pause
	
# Здоровье игрока
var max_player_health: float = 300
var player_health: float = max_player_health:
	set(value):
		if value > player_health:
			player_health = min(value, max_player_health)
		else:
			if is_player_vulnerable:
				player_health = value
				is_player_vulnerable = false
				PlayerInvulnerabilityTimer.start()
				switch_player_white_color.emit()
		stat_change.emit()
			
func player_vulnerable() -> void:
	is_player_vulnerable = true
	switch_player_white_color.emit()

# Выход из игры
func quit_game() -> void:
	get_tree().quit()

# Переключение сцены
func change_scene(scene_path : String) -> void:
	get_tree().change_scene_to_file(scene_path)
