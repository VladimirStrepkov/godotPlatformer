extends CanvasLayer


func _on_exit_button_pressed() -> void:
	Globals.quit_game()


func _on_new_game_button_pressed() -> void:
	Globals.change_scene("res://scenes/levels/level_1.tscn")
