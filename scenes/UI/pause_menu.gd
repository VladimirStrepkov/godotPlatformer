extends CanvasLayer

func _ready() -> void:
	# Этот узел будет обрабатываться только во время паузы
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	Globals.connect("pause_menu_switch", pause_menu_switch)

func pause_menu_switch() -> void:
	if Globals.is_pause:
		show()
	else:
		hide()

func _on_continue_button_pressed() -> void:
	Globals.is_pause = false

func _on_exit_game_button_pressed() -> void:
	Globals.quit_game()

func _on_main_menu_button_pressed() -> void:
	Globals.change_scene("res://scenes/UI/main_menu.tscn")

func _on_load_button_pressed() -> void:
	Globals.load_game()
