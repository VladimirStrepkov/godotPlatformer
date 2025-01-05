extends PeriodicTraps

# Сила толчка
@export var pushing_force: float

# Джампер толкает игрока
func interaction() -> void:
	player.push_player(-pushing_force)
	# Создаём эффект
	Globals.create_effect("air_dash_effect", global_position, false, deg_to_rad(90))

func _ready() -> void:
	# Изначально джампер неактивен
	is_active = false
	# Функция "start" откладывается до конца физического кадра
	# чтобы переменные успели загрузиться
	call_deferred("start")
