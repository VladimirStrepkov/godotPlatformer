extends CanvasLayer

func _ready() -> void:
	Globals.connect("stat_change", stat_change)

# Обновление статов в интерфейсе
func stat_change() -> void:
	$ProgressBar.value = 100 * (Globals.player_health / Globals.max_player_health)
