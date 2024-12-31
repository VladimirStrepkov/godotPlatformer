extends CharacterBody2D

# Скорость игрока
var speed: float
# Скорость ходьбы игрока
var walk_speed: float = 30.0
# Скорость бега игрока
var run_speed: float = 100.0
# Высота прыжка игрока
var jump_velocity: float = -400.0

# Умер ли персонаж игрока (когда кончается здоровье)
var does_player_died: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("idle")
	Globals.connect("switch_player_white_color", switch_player_white_color)
	Globals.connect("get_player_data", get_player_data)
	Globals.connect("player_died", player_died)
	
	# Берём значения свойств этого узла из globals
	if Globals.nodes_take_data_from_globals:
		set_player_data()

# Функция смерти игрока
func player_died() -> void:
	does_player_died = true

# Функция передачи данных об узле (значений свойств узла) скрипту globals
func get_player_data() -> void:
	Globals.player_data = {
		"global_position" : global_position
	}

# Узел берёт значения для некоторых своих свойств из globals
func set_player_data() -> void:
	# Проходимся по ключам словаря
	for property in Globals.player_data.keys():
		set(property, Globals.player_data[property])

# Функция сохранения узла (какие данные об узле нужно сохранять)
# Т.к. узел находится в группе "SavedNodes", эта функция будет вызываться при сохранении прогресса
func save() -> Dictionary:
	var save_dict = {
		"global_position" : global_position
	}
	return save_dict

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
	if Input.is_action_just_pressed("accept") and is_on_floor() and Globals.player_can_move:
		velocity.y = jump_velocity
		
	# В зависимости от нажатия ctrl меняем скорость игрока (ходьба/бег)
	if Input.is_action_pressed("ctrl"):
		speed = walk_speed
	else:
		speed = run_speed

	# В зависимости от нажатых кнопок меняем направление движения
	var direction = Input.get_axis("left", "right")
	if direction and Globals.player_can_move:
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
	if does_player_died:
		if a != "death":
			anim.play("death")
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
