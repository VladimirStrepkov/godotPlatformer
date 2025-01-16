extends Enemy

var ball_scene = preload("res://scenes/projectiles/ball.tscn")

func attack():
	var ball = ball_scene.instantiate()
	ball.dir = (player.global_position - global_position + Vector2(0, 8)).normalized()
	ball.global_position = global_position + Vector2(0, -20)
	if $AnimatedSprite2D.flip_h:
		ball.global_position += Vector2(-10, 0)
	else:
		ball.global_position += Vector2(10, 0)
	ball.damage = damage
	get_tree().get_current_scene().get_node("Projectiles").add_child(ball)
