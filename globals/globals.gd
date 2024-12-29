extends Node
# Здесь будут храниться глобальные переменные

# уязвим ли игрок
var is_player_vulnerable: bool = true

# Переключение белого цвета спрайта игрока (при получении урона/конце неуязвимости)
signal switch_player_white_color

# Обновление интерфейса
signal stat_change

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
				player_invulnerability_timer()
				switch_player_white_color.emit()
		stat_change.emit()
			

func player_invulnerability_timer() -> void:
	await get_tree().create_timer(0.3).timeout
	is_player_vulnerable = true
	switch_player_white_color.emit()
