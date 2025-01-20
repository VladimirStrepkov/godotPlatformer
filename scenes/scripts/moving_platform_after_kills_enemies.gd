extends Node

# Число убитых на уровне врагов
var count_died_enemies: int = 0

func _ready() -> void:
	$"../../Objects/MovingPlatformType2".speed = 0

# Каждый раз когда враг умирает
func _on_enemies_child_exiting_tree(_node: Node) -> void:
	count_died_enemies += 1
	# Активируем платформу если умерло 9 врагов
	if count_died_enemies == 9:
		$"../../Objects/MovingPlatformType2".speed = 30
		if Globals.current_level == Globals.dangeon_level:
			Globals.show_message("Платформа активирована")
	elif count_died_enemies < 9:
		if Globals.current_level == Globals.dangeon_level:
			Globals.show_message("Осталось убить " + str(9 - count_died_enemies) + " врагов")
