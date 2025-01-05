extends RigidBody2D

# Направление движения ящика (1 - вправо, -1 - влево, 0 - никуда)
var movement_direction_x: float = 0

func set_movement_direction(movement_direction) -> void:
	movement_direction_x = movement_direction

func _ready() -> void:
	# Блокируем поворот для твёрдого тела
	lock_rotation = true

func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(20, 0) * delta * movement_direction_x)

func _on_interaction_zone_body_entered(body: Node2D) -> void:
	Globals.show_hint("E - перемещать")
	body.switch_box_interaction(self)

func _on_interaction_zone_body_exited(body: Node2D) -> void:
	Globals.hide_hint()
	body.switch_box_interaction(self)
