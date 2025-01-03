extends AnimatedSprite2D

# Эффект уничтожается после того как его анимация проиграется
func _on_animation_finished() -> void:
	self.queue_free()
