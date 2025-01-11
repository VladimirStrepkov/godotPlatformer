extends Area2D

# Ключ для файла сохранения (objects_save_data). Должен быть уникальным у 
# каждого экземпляра сцены. Если мы подобрали бонус и сохранились, то при 
# загрузке игры этот бонус уже не будет загружаться в сцену.
@export var save_key: String

func _on_body_entered(_body: Node2D) -> void:
	Globals.player_health += 100
	Globals.objects_save_data[save_key] = false
	queue_free()

func _ready() -> void:
	# Если в Globals есть информация об этом узле и если этот узел уже был подобран, то
	# мы больше не будем создавать этот узел при загрузке сцены
	if Globals.objects_save_data.has(save_key):
		if not Globals.objects_save_data[save_key]:
			queue_free()
	else:
		Globals.objects_save_data[save_key] = true
