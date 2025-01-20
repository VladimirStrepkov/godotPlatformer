extends Enemy

var ball_scene = preload("res://scenes/projectiles/ball.tscn")

# Скорость выпускаемых шаров
@export var ball_speed: int = 50

func attack():
	var ball = ball_scene.instantiate()
	ball.dir = (player.global_position - global_position + Vector2(0, 8)).normalized()
	ball.global_position = global_position + Vector2(0, -20)
	if $AnimatedSprite2D.flip_h:
		ball.global_position += Vector2(-10, 0)
	else:
		ball.global_position += Vector2(10, 0)
	ball.damage = damage
	ball.speed = ball_speed
	get_tree().get_current_scene().get_node("Projectiles").add_child(ball)
