extends CharacterBody2D

# Направление движения ящика (1 - вправо, -1 - влево, 0 - никуда)
var movement_direction_x: float = 0

func set_movement_direction(movement_direction) -> void:
	movement_direction_x = movement_direction

func _physics_process(_delta: float) -> void:
	# Если игрок умер, то ящики падают на него (выключаем у них слой коллизий игрока)
	if Globals.player_health == 0:
		collision_mask &= ~0b0000001  # Убираем 1-й бит (слой 1)
	
	# Вектор гравитации
	var gravity_vector = Vector2(0, 200)
	
	# Столкновение с ящиком справа
	if $Right1.is_colliding() and movement_direction_x != 0:
		$Right1.get_collider().set_movement_direction(1)
	if $Right2.is_colliding() and movement_direction_x != 0:
		$Right2.get_collider().set_movement_direction(1)
	if $Right3.is_colliding() and movement_direction_x != 0:
		$Right3.get_collider().set_movement_direction(1)
	# Столкновение с ящиком слева
	if $Left1.is_colliding() and movement_direction_x != 0:
		$Left1.get_collider().set_movement_direction(-1)
	if $Left2.is_colliding() and movement_direction_x != 0:
		$Left2.get_collider().set_movement_direction(-1)
	if $Left3.is_colliding() and movement_direction_x != 0:
		$Left3.get_collider().set_movement_direction(-1)
		
	# Запоминаем позицию до перемещения
	var old_pos_x = global_position.x
	
	# Перемещение
	velocity = gravity_vector + Vector2(20, 0) * movement_direction_x
	move_and_slide()
	
	# Если на ящике другой ящик, то мы приподнимаем ящик чтобы он мог двигаться по земле
	# Если этого не делать, то игрок не сможет передвигать ящик, на к-м стоит другой ящик
	# т.е. это костыль :D
	if old_pos_x == global_position.x and movement_direction_x != 0 and not is_on_wall():
		global_position.y -= 1
	
	# Обнуляем вектор направления
	movement_direction_x = 0

func _on_interaction_zone_body_entered(body: Node2D) -> void:
	Globals.show_hint("E - перемещать")
	body.switch_box_interaction(self)

func _on_interaction_zone_body_exited(body: Node2D) -> void:
	Globals.hide_hint()
	body.switch_box_interaction(self)
