extends Area2D
# Идея: игрок входит в зону, начинается "катсцена", в которой камера игрока проходит
# по наиболее важным точкам уровня, после чего возвращается к игроку. Таким образом
# игрок лучше понимает, куда ему идти и что делать.

# Массив точек, по которым будет двигаться камера после вхождения игрока в зону
# Пусть n - количество точек
@export var markers_array: Array[Marker2D]

# Камера которая будет двигаться по точкам
@export var camera: Camera2D

# Значения времени, которые камера будет затрачивать на перемещение между точками
# (между игроком и 1 маркером, между 1 и 2 маркером, ..., между n-ым маркером и игроком)
# Всего n + 1 элементов
@export var movement_times: Array[float]

# Значения времени, на которые камера будет останавливаться в каждой точке
# (в точке игрока, в точке 1-ого маркера, в точке 2-го маркера, ..., в точке игрока)
# Всего n + 2 элементов
@export var viewing_times: Array[float]

# Ключ для файла сохранения (objects_save_data). Должен быть уникальным у 
# каждого экземпляра сцены. Если мы подобрали бонус и сохранились, то при 
# загрузке игры этот бонус уже не будет загружаться в сцену.
@export var save_key: String

func _ready() -> void:
	# Если в Globals есть информация об этом узле и если этот узел уже был подобран, то
	# мы больше не будем создавать этот узел при загрузке сцены
	if Globals.objects_save_data.has(save_key):
		if not Globals.objects_save_data[save_key]:
			queue_free()
	else:
		Globals.objects_save_data[save_key] = true

# Игрок вошёл в зону
func _on_body_entered(_body: Node2D) -> void:
	# Включаем "режим кино" в UI
	Globals.switch_ui_mode()
	# "Обездвиживаем" игрока
	Globals.player_can_move = false
	# n - количество маркеров
	var n = len(markers_array)
	var tween
	
	# Пока игрок не упадёт на пол, не будем запоминать начальное положение камеры
	while not camera.get_parent().is_on_floor():
		await get_tree().create_timer(1).timeout
		
	# Запоминаем начальное расположение камеры (игрок)
	var start_position = camera.global_position
	for i in range(n):
		# Смотрим какое-то время на точку, если этот узел существует
		if is_inside_tree():
			await get_tree().create_timer(viewing_times[i]).timeout
		# летим к следующей точке
		tween = get_tree().create_tween()
		tween.tween_property(camera, "global_position", markers_array[i].global_position, movement_times[i])
		# Ждём пока долетим к следующей точки
		await get_tree().create_timer(movement_times[i]).timeout
	# Смотрим на последнюю точку
	await get_tree().create_timer(viewing_times[n]).timeout
	# Летим обратно к игроку
	tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", start_position, movement_times[n])
	# Ждём пока долетим до игрока
	await get_tree().create_timer(movement_times[n]).timeout
	# Смотрим на игрока
	await get_tree().create_timer(viewing_times[n + 1]).timeout
	
	# Игрок снова может двигаться
	Globals.player_can_move = true
	
	# Выключаем "режим кино" в ui
	Globals.switch_ui_mode()
	
	# Удаляем все маркеры
	for marker in markers_array:
		marker.queue_free()
	
	# Сообщаем глобальному скрипту что мы подобрали эту зону
	Globals.objects_save_data[save_key] = false
	# Удаляем зону
	queue_free()
