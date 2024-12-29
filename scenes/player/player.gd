extends CharacterBody2D

# Скорость игрока
var speed: float
# Скорость ходьбы игрока
var walk_speed: float = 30.0
# Скорость бега игрока
var run_speed: float = 100.0
# Высота прыжка игрока
var jump_velocity: float = -400.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("idle")
	Globals.connect("switch_player_white_color", switch_player_white_color)

# Делаем спрайт игрока белым если игрок получил урон
# Или делаем спрайт обычным если игрок вышел из неуязвимости
func switch_player_white_color() -> void:
	if Globals.is_player_vulnerable:
		$AnimatedSprite2D.material.set_shader_parameter("progress", 0)
	else:
		$AnimatedSprite2D.material.set_shader_parameter("progress", 1)

func _physics_process(delta):
	# Добавляем гравитацию
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("accept") and is_on_floor():
		velocity.y = jump_velocity
		
	# В зависимости от нажатия ctrl меняем скорость игрока (ходьба/бег)
	if Input.is_action_pressed("ctrl"):
		speed = walk_speed
	else:
		speed = run_speed

	# В зависимости от нажатых кнопок меняем направление движения
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	update_animation()
	move_and_slide()

func update_animation():
	# Меняем направление спрайтов в зависимости от скорости по x
	# положение x тоже меняем т.к. кадры не симметричные по оси x
	if velocity.x > 0:
		anim.flip_h = false
		anim.position.x = 7
	elif velocity.x < 0:
		anim.flip_h = true
		anim.position.x = -10 
	
	# Эти переменные нужны для сокращения кода
	var a = anim.animation
	var vx = velocity.x
	var vy = velocity.y
	
	# Меняем анимацию в зависимости от скорости персонажа и текущей анимации
	if a != "jump" and a != "fall" and vy < 0:
		anim.play("jump")
	elif a == "jump" and not anim.is_playing():
		anim.play("fall")
	elif a != "fall" and vy > 0:
		anim.play("fall")
	elif a == "fall" and vy == 0:
		anim.play("landing")
	elif a == "landing" and not anim.is_playing():
		anim.play("idle")
	elif vx != 0 and vy == 0:
		if speed == run_speed:
			anim.play("run")
		else:
			anim.play("walk")
	elif (a == "run" or a == "walk") and vx == 0:
		anim.play("idle")
