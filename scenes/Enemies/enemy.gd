extends Node2D

# Создание нового вида врагов
# 1) Создать animatedSprite2D и добавить к нему шейдер white_color.gdshader
# 2) Создать анимации: idle, walk, death, attack, 
# 3) Указать максимальное здоровье (max_health)
# 4) Создать формы столкновений для NoticeArea, AttackArea, Enemy
# 5) Указать speed
# 6) Задать anim_left_x и anim_right_x
# 7) задать attack_frame
# 8) задать damage
# 9) 


# Создание нового врага
# 0) Создаём родительский узел node2D (В нем будут все маркеры)
# 1) Указать random_movement
# 2) Задать левую и правую границы передвижения врага по x
# 3) Задать точки movement_points (Если не random_movement)
# 4) Задать значения времени point_wait_times (Если не random_movement)
# 5) 


@export var anim: AnimatedSprite2D

@export var max_health: int
var health:
	set(value):
		health = max(value, 0)
		$HealthBar.value = floor((float(health) / max_health) * 100)
		if health == 0 and anim.animation != "death":
			anim.play("death")

# Случайное ли у врага передвижение
@export var random_movement = true

# Левая и правая границы передвижения врага по x
@export var left_limit_of_movement: Marker2D
@export var right_limit_of_movement: Marker2D

# Массив точек передвижения
# Если random_movement=true, то массив пустой
# враг будет случайно передвигаться между границами (как НПС)
# Если random_movement=false, то враг будет циклично последовательно двигаться
# от одной точки к другой
# Причём на i-ой точке враг будет стоять point_wait_times[i] секунд
@export var movement_points: Array[Marker2D]

# Если random_movement=true, то этот массив пустой.
# Иначе здесь будут храниться значения времени, которое враг будет стоять на
# точках перемещения
@export var point_wait_times: Array[float]

# Индекс текущей точки перемещения
var point_index: int = 0

# Скорость, с которой двигается враг
@export var speed: float = 12

# Из-за несимметричных кадров при повороте AnimatedSprite2D нужно учитывать смещение
@export var anim_left_x: int  # положение узла AnimatedSprite2D когда он повёрнут влево
@export var anim_right_x: int

# Значение x, к которому будет передвигаться враг
var target_x: float

# Видит ли враг игрока (NoticeArea)
var sees_player: bool = false
# Может ли атаковать враг игрока (AttackArea)
var can_attack: bool = false

# В каком кадре анимации атаки наносить игроку урон
@export var attack_frame: int = 0

# Сколько урона игроку наносит удар врага
@export var damage: int = 30

var player

func _ready() -> void:
	target_x = global_position.x
	health = max_health

# По умолчанию враг просто наносит урон игроку
# Можно например создавать проджекттайлы вместо этого
func attack():
	Globals.player_health -= damage
	
func  _process(delta: float) -> void:	
	# Удаляем врага со сцены
	if anim.animation == "death" and not anim.is_playing():
		get_parent().queue_free()
	
	# Враг умер
	if health == 0:
		return
	
	# Враг движется в сторону игрока если видит его
	if sees_player:
		target_x = player.global_position.x
	
	# Целевая позиция не может выходить за рамки границ
	target_x = max(target_x, left_limit_of_movement.global_position.x)
	target_x = min( target_x, right_limit_of_movement.global_position.x)
	
	# Меняем направление спрайта в зависимости от расположения целевой точки
	turn_to_x(target_x)
	
	# Атакуем игрока если можем это сделать и видим игрока
	if can_attack and sees_player and anim.animation != "attack":
		anim.play("attack")
	
	# Атакуем
	if anim.animation == "attack" and anim.frame == attack_frame and can_attack:
		attack()
	
	# Анимация атаки закончилась
	if anim.animation == "attack":
		if not anim.is_playing():
			anim.play("idle")
		else:
			return
	
	# Если враг не атакует и не на целевой позиции, то он к ней двигается
	if abs(target_x - global_position.x) >= speed * delta and not (anim.animation == "attack" and anim.is_playing()):
		# dir - Направление движения НПС
		var dir: int
		if target_x > global_position.x:
			dir = 1
		else:
			dir = -1
		global_position.x += speed * delta * dir
		if anim.animation == "idle":
			anim.play("walk")
	# Если же враг на целевой позиции и таймер бездействия ещё не запущен
	# то он запускается
	elif $IdleTimer.is_stopped():
		idle_timer_start()
		# Пока враг бездействует, его анимация - idle
		anim.play("idle")

func idle_timer_start():
	if random_movement:
		$IdleTimer.start(randi() % 8)
	else:
		$IdleTimer.wait_time = point_wait_times[point_index]
		$IdleTimer.start()
		
func _on_idle_timer_timeout() -> void:
	# Выбираем новую точку, к которой будет двигаться враг в пределах границ
	if random_movement:
		target_x = randi_range(int(left_limit_of_movement.global_position.x), int(right_limit_of_movement.global_position.x))
	else:
		point_index = (point_index + 1) % len(point_wait_times)
		target_x = movement_points[point_index].global_position.x

# Поворачиваем врага к заданной x-координате
# Учитываем смещение при несимметричных кадрах
func turn_to_x(x: float) -> void:
	if x > global_position.x:
		anim.flip_h = false
		anim.position.x = anim_right_x
		$NoticeArea.scale.x = -1
		$AttackArea.scale.x = -1
	else:
		anim.flip_h = true
		anim.position.x = anim_left_x
		$NoticeArea.scale.x = 1
		$AttackArea.scale.x = 1


# Враг замечает игрока
func _on_notice_area_body_entered(body: Node2D) -> void:
	sees_player = true
	player = body
	# Если запущен таймер забывания, то он останавливается
	if not $MemoryTimer.is_stopped():
		$MemoryTimer.stop()

# Игрок выходит из NoticeArea
func _on_notice_area_body_exited(_body: Node2D) -> void:
	# Враг ещё какое-то время видит игрока (у врага есть память)
	# Запускаем таймер если он есть в дереве
	if $MemoryTimer.is_inside_tree():
		$MemoryTimer.start()

# Враг "забывает" игрока
func _on_memory_timer_timeout() -> void:
	sees_player = false


func _on_attack_area_body_entered(_body: Node2D) -> void:
	can_attack = true

func _on_attack_area_body_exited(_body: Node2D) -> void:
	can_attack = false

# Врага атаковали
func hit():
	if $HitTimer.is_stopped() and health > 0:
		anim.material.set_shader_parameter("progress", 1)
		health -= 30
		$HitTimer.start()
		

func _on_hit_timer_timeout() -> void:
	anim.material.set_shader_parameter("progress", 0)
