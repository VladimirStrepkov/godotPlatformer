extends Area2D

# Время бездействия шипов
@export var idle_time: float

# Время нахождения шипов в активированном режиме
@export var activity_time: float

# Активны ли шипы
var is_active: bool = false

# Стоит ли игрок на шипах
var is_player_near: bool = false

# Функция переключения шипов
func switch() -> void:
	is_active = not is_active

func _ready() -> void:
	# Функция "start" откладывается до конца физического кадра
	# чтобы переменные успели загрузиться
	call_deferred("start")

func _process(_delta: float) -> void:
	# Если шипы активированны и игрок на них стоит, то игроку наносится урон
	if is_active and is_player_near:
		Globals.player_health -= 20

# Задаю установленные значения времени бездействия и активации
func start() -> void:
	$Timers/IdleTimer.wait_time = idle_time
	$Timers/ActivityTimer.wait_time = activity_time
	$Timers/IdleTimer.start()

func _on_idle_timer_timeout() -> void:
	$AnimationPlayer.play("activation")
	$Timers/ActivityTimer.start()


func _on_activity_timer_timeout() -> void:
	$AnimationPlayer.play("deactivation")
	$Timers/IdleTimer.start()


func _on_body_entered(_body: Node2D) -> void:
	is_player_near = true

func _on_body_exited(_body: Node2D) -> void:
	is_player_near = false
