extends Camera2D

# Правая и левая границы камеры
@export var left_limit: Marker2D
@export var right_limit: Marker2D

func _ready() -> void:
	Globals.connect("camera_zoom", camera_zoom)
	Globals.connect("camera_zoom_out", camera_zoom_out)
	# Устанавливаю границы для камеры
	self.limit_left = int(left_limit.global_position.x)
	self.limit_right = int(right_limit.global_position.x)

func camera_zoom() -> void:
	# Проверяем, находится ли текущий узел внутри дерева узлов
	if is_inside_tree():
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "zoom", Vector2(1.3, 1.3), 1)
		tween.tween_property(self, "position:y", -30, 1)

func camera_zoom_out() -> void:
	# Проверяем, находится ли текущий узел внутри дерева узлов
	if is_inside_tree():
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "zoom", Vector2(1, 1), 1)
		tween.tween_property(self, "position:y", -50, 1)
