extends PeriodicTraps

# Сила толчка
@export var pushing_force: float

# Включается ли Джампер автоматически
@export var auto_start: bool = true

# Толкнул ли джампер игрока в этом толчке (нужно чтобы джампер не толкал игрока несколько раз)
var pushed: bool
func not_pushed() -> void:
	pushed = false

# Джампер толкает игрока если он его еще не толкал в этом толчке
func interaction() -> void:
	if not pushed:
		player.push_player(-pushing_force)
		# Создаём эффект
		Globals.create_effect("air_dash_effect", global_position, false, deg_to_rad(90))
		# Джампер не может толкать игрока несколько раз за один толчок
		pushed = true

func _ready() -> void:
	# Изначально джампер неактивен
	is_active = false
	# Функция "start" откладывается до конца физического кадра
	# чтобы переменные успели загрузиться
	if auto_start:
		call_deferred("start")

# Включаем Джампер извне
func on_function() -> void:
	is_active = false
	$Timers/IdleTimer.start()

# Выключаем Джампер извне
func off_function() -> void:
	$AnimationPlayer.stop()
	$Timers/IdleTimer.stop()
	$Timers/ActivityTimer.stop()
