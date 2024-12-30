extends CanvasLayer

func _on_exit_button_pressed() -> void:
	Globals.quit_game()

func _on_new_game_button_pressed() -> void:
	Globals.new_game()

func _on_continue_button_pressed() -> void:
	Globals.load_game()
