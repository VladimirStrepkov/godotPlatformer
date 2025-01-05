extends Area2D

func _on_body_entered(body: Node2D) -> void:
	body.enable_double_jump(self)

func _on_body_exited(body: Node2D) -> void:
	body.disable_double_jump()

# Объектом двойного прыжка воспользовался игрок
func activate() -> void:
	$ActivityTimer.start()
	$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
	Globals.create_effect("double_jump_effect", global_position)

func _on_activity_timer_timeout() -> void:
	$AnimatedSprite2D.modulate.r = 255
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)
