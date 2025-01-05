extends Area2D

# Это сцена-шаблон периодической ловушки, она находится определённое время в неактивном
# режиме, в котором не наносит урон, а потом активируется и находится определённое время в
# активном режиме в котором наносит урон, далее деактивируется и т.д.
# В наследниках этой сцены нужно:
# 1) добавить таблицу спрайтов анимации ловушки в AnimationSpriteSheet
# 2) добавить AnimationPlayer
# 3) создать анимации "activation" и "deactivation" в AnimationPlayer
# 4) Добавить вызов функции switch в AnimationPlayer (Если это требуется)
# 5) добавить и настроить collisionShape

# Время бездействия ловушки
@export var idle_time: float

# Время нахождения ловукши в активированном состоянии
@export var activity_time: float

# Активна ли ловушка
var is_active: bool = true

# Стоит ли игрок на ловушке
var is_player_near: bool = false

# Урон к-й наносится игроку когда он стоит на активной ловушке
@export var damage: float

# Функция переключения ловушки
func switch() -> void:
	is_active = not is_active

func _ready() -> void:
	# Функция "start" откладывается до конца физического кадра
	# чтобы переменные успели загрузиться
	call_deferred("start")

func start() -> void:
	$Timers/IdleTimer.wait_time = idle_time
	$Timers/ActivityTimer.wait_time = activity_time
	$Timers/ActivityTimer.start()


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

func _process(_delta: float) -> void:
	# Если ловушка активна и игрок на ней стоит, то игроку наносится урон
	if is_active and is_player_near:
		Globals.player_health -= damage
