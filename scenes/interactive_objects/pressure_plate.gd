extends SwitchObject

# Число объектов стоящих на плите (если 0, то плита неактивна, иначе активна)
var num_obj_on_plate: int = 0

func _ready() -> void:
	show_hint_text = false

func _on_plate_area_body_entered(_body: Node2D) -> void:
	if num_obj_on_plate == 0:
		activate()
		$AnimatedSprite2D.play("on")
	num_obj_on_plate += 1

func _on_plate_area_body_exited(_body: Node2D) -> void:
	if num_obj_on_plate == 1:
		deactivate()
		$AnimatedSprite2D.play("off")
	num_obj_on_plate -= 1
