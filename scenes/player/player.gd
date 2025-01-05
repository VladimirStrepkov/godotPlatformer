extends CharacterBody2D

# Скорость игрока
var speed: float
# Скорость ходьбы игрока
var walk_speed: float = 30.0
# Скорость бега игрока
var run_speed: float = 100.0
# Высота прыжка игрока
var jump_velocity: float = -400.0

# Скорость которую добавляет рывок (после рывка постепенно уменьшается до 0)
var dash_speed: float = 0:
	set(value):
		# не может быть отрицательным
		dash_speed = max(0, value)

# Взбирается ли игрок по лестнице
var player_climbs: bool = false
# Может ли игрок взбираться по лестнице
var player_can_climb: bool = false:
	set(value):
		player_can_climb = value
		# Игрок не ползёт по лестнице если он не может ползти по лестнице
		if not value:
			player_climbs = false

# Умер ли персонаж игрока (когда кончается здоровье)
var does_player_died: bool = false:
	set(value):
		does_player_died = value
		# Если игрок умирает, то он слетает с лестницы
		if value:
			player_climbs = false

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
	if not is_on_floor() and not player_climbs:
		velocity += get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("accept") and (is_on_floor() or player_climbs) and Globals.player_can_move:
		velocity.y = jump_velocity
	
	# если игрок нажимает "w" и он может ползти по лестнице, то он ползёт по лестнице
	if Input.is_action_just_pressed("top") and player_can_climb and not player_climbs:
		player_climbs = true
	
	# Если игрок нажимает "space", "a", "d", то он слезает с лестницы
	if Input.is_action_just_pressed("accept") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left"):
		player_climbs = false
	
	# Добавляем движение по лестнице
	
	# Выбираем направление движения по лестнице
	var ladder_direction = Input.get_axis("top", "down")
	# Добавляем движение
	if player_climbs and Globals.player_can_move:
		velocity.y = ladder_direction * 30
		
	# В зависимости от нажатия ctrl меняем скорость игрока (ходьба/бег)
	if Input.is_action_pressed("ctrl"):
		speed = walk_speed
	else:
		speed = run_speed
	
	# В зависимости от нажатых кнопок меняем направление движения
	var direction = Input.get_axis("left", "right")
	
	# Если нажата клавиша shift, то персонаж совершает рывок
	if Input.is_action_just_pressed("shift") and Globals.player_can_move and $Timers/DashTimer.is_stopped() and direction:
		dash_speed = 300
		$Timers/DashTimer.start()
		# СОЗДАЁМ ЭФФЕКТ ПОСЛЕ РЫВКА ---------------------------------------------------
		# Имя эффекта, который будет создаваться при рывке
		var name_effect: String;
		# Смещение позиции эффекта относительно игрока
		var position_shift_x: float
		var position_shift_y: float
		# Нужно ли отражать спрайт эффекта по горизонтали
		var flip_hor = (direction == 1)
		
		if is_on_floor():
			name_effect = "dash_effect"
			position_shift_x = 26
			position_shift_y = 9
		else:
			name_effect = "air_dash_effect"
			position_shift_x = 14
			position_shift_y = 0
		
		if flip_hor:
			position_shift_x = -position_shift_x
		
		var position_shift = Vector2(position_shift_x, position_shift_y)
		
		Globals.create_effect(name_effect, global_position + position_shift, flip_hor)

	speed += dash_speed
	dash_speed -= 20
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
	elif dash_speed > 0:
		if a != "dash":
			anim.play("dash")
	elif dash_speed == 0 and a == "dash":
		anim.play("idle")
	elif player_climbs:
		# Если игрок неподвижно стоит на лестнице, то ставим анимацию на паузу
		if a != "climb" or vy == 0:
			anim.play("climb")
			anim.pause()
		# Если игрок ползёт вверх, то проигрываем анимацию
		elif vy < 0:
			anim.play("climb")
		# Если игрок ползёт вниз, то проигрываем анимацию в обратном порядке
		elif vy > 0:
			anim.play_backwards("climb")
	elif a != "jump" and a != "fall" and vy < 0:
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
