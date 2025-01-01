extends InteractiveObject

# В наследниках этой сцены обязательно должен быть узел AnimatedSprite2D
# у этого узла должны быть цикличные анимации idle и walk
@export var anim: AnimatedSprite2D

# Из-за несимметричных кадров при повороте AnimatedSprite2D нужно учитывать смещение
@export var anim_left_x: int  # положение узла AnimatedSprite2D когда он повёрнут влево
@export var anim_right_x: int

# Левая и правая границы передвижения НПС по x
@export var left_limit_of_movement: Marker2D
@export var right_limit_of_movement: Marker2D

# Значение x, к которому будет передвигаться НПС
var target_x: float

# Скорость, с которой двигается НПС
var speed: float = 12

# Разговаривает ли игрок с этим НПС
var dialogue: bool = false

func _ready() -> void:
	hint_text = "E - поговорить"
	target_x = global_position.x

func _process(delta: float) -> void:
	# Если игрок разговаривает с НПС, то НПС не передвигается
	if dialogue:
		return
	
	# Если НПС не на целевой позиции, то он к ней двигается
	if abs(target_x - global_position.x) >= speed * delta:
		# dir - Направление движения НПС
		var dir: int
		if target_x > global_position.x:
			dir = 1
		else:
			dir = -1
		global_position.x += speed * delta * dir
	# Если же НПС на целевой позиции и таймер бездействия ещё не запущен
	# то он запускается
	elif $IdleTimer.is_stopped():
		idle_timer_start()
		# Пока НПС бездействует, его анимация - idle
		anim.play("idle")

# Запустить таймер бездействия НПС на случайное время
func idle_timer_start() -> void:
	$IdleTimer.start(randi() % 8)

func _on_idle_timer_timeout() -> void:
	# Выбираем новую точку, к которой будет двигаться НПС в пределах границ
	target_x = randi_range(int(left_limit_of_movement.global_position.x), int(right_limit_of_movement.global_position.x))
	# Пока НПС двигается к точке, его анимация - walk
	anim.play("walk")
	# Меняем направление спрайта в зависимости от расположения целевой точки
	# Учитываем смещение при несимметричных кадрах
	if target_x > global_position.x:
		anim.flip_h = false
		anim.position.x = anim_right_x
	else:
		anim.flip_h = true
		anim.position.x = anim_left_x
