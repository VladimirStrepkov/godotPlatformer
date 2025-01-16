extends Area2D

@export var damage: int

@export var speed: int

@export var dir: Vector2

func _process(delta: float) -> void:
	global_position += speed * dir * delta
	
@export var effect_name: String

func destroy() -> void:
	Globals.create_effect(effect_name, global_position)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.player_health -= damage
	destroy()

# Любой снаряд самоуничтножается через какое-то время
# (чтобы снаряды не могли лететь вечно)
func _on_timer_timeout() -> void:
	destroy()
