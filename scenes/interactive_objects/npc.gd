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
var dialogue: bool = false:
	set(value):
		dialogue = value
		# Если начинается диалог, то целевая позиция становится равной текущей позиции
		# анимация меняется на idle, НПС поворачивается к игроку
		if value:
			anim.play("idle")
			target_x = global_position.x
			turn_to_x(player.position.x)

# Имя НПС (будет отображаться в диалоге)
@export var npc_name: String

# Номер диалога у этого НПС (ключ к словарю диалогов в dialogue_storage)
@export var dialogue_number: int

# Храним ссылку на игрока в этой переменной. НПС должен знать где находится игрок,
# чтобы при начале диалога повернуться в его сторону
var player

func when_player_in(player_body) -> void:
	Globals.dialogue_info["player_can"] = true
	Globals.dialogue_info["npc"] = self
	player = player_body

func when_player_out() -> void:
	Globals.dialogue_info["player_can"] = false
	
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
	# Если игрок разговаривает с НПС, то НПС не выбирает новую целевую точку
	if dialogue:
		return
	# Выбираем новую точку, к которой будет двигаться НПС в пределах границ
	target_x = randi_range(int(left_limit_of_movement.global_position.x), int(right_limit_of_movement.global_position.x))
	# Пока НПС двигается к точке, его анимация - walk
	anim.play("walk")
	# Меняем направление спрайта в зависимости от расположения целевой точки
	turn_to_x(target_x)

# Поворачиваем НПС к заданной x-координате
# Учитываем смещение при несимметричных кадрах
func turn_to_x(x: float) -> void:
	if x > global_position.x:
		anim.flip_h = false
		anim.position.x = anim_right_x
	else:
		anim.flip_h = true
		anim.position.x = anim_left_x
