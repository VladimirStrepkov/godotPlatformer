extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("idle")


func _physics_process(delta):
	# Добавляем гравитацию
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# В зависимости от нажатых кнопок меняем направление движения
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
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
	
	# Меняем анимацию в зависимости от скорости персонажа и текущей анимации
	if anim.animation != "jump" and anim.animation != "fall" and velocity.y < 0:
		anim.play("jump")
	elif anim.animation == "jump" and not anim.is_playing():
		anim.play("fall")
	elif anim.animation != "fall" and velocity.y > 0:
		anim.play("fall")
	elif anim.animation == "fall" and velocity.y == 0:
		anim.play("landing")
	elif anim.animation == "landing" and not anim.is_playing():
		anim.play("idle")
	elif velocity.x != 0 and velocity.y == 0:
		anim.play("run")
	elif anim.animation == "run" and velocity.x == 0:
		anim.play("idle")
